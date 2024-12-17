import 'dart:io';

import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;

// ignore: public_member_api_docs
enum StubHttpMethod { get, post, put, delete, any }

/// The expected response from a request.
class StubOfflineFirstRestResponse {
  /// The path where the [response] should be returned. Avoid leading slashes.
  ///
  /// This does not include the base URL or domain. For example,
  /// `users` not `http://0.0.0.0:3000/api/users`.
  final String endpoint;

  /// Limit this [response] to only return for a specific HTTP method;
  /// defaults to `any`, meaning the [response] will be returned regardless
  /// of the request.
  final StubHttpMethod method;

  /// The text returned from the HTTP request.
  final String response;

  ///
  static String get currentDirectory {
    // `flutter test` and `dart test` resolve with different values
    // https://github.com/flutter/flutter/issues/20907
    final directory = Platform.script.path.contains('/dart_test')
        ? Directory.current.path
        : p.dirname(Platform.script.path);
    // when running this script from the project (i.e. `flutter test`),
    // the directory is where main.dart lives. We want the test directory.
    if (directory.contains('/test')) {
      return directory;
    }

    return p.join(directory, 'test');
  }

  /// The expected response from a request.
  StubOfflineFirstRestResponse(
    this.response, {
    required this.endpoint,
    StubHttpMethod? method,
  }) : method = method ?? StubHttpMethod.any;

  ///
  factory StubOfflineFirstRestResponse.fromFile(
    String filePath, {
    required String endpoint,
    StubHttpMethod? method,
  }) {
    final apiFile = File(p.join(currentDirectory, filePath));
    return StubOfflineFirstRestResponse(
      apiFile.readAsStringSync(),
      endpoint: endpoint,
      method: method,
    );
  }
}

/// Generate mocks for an [OfflineFirstWithRestModel]. Instantiation automatically stubs REST responses.
///
/// For convenience, your data structure only needs to be defined once. Include a sample API
/// response in a sibling `/api/` directory (`api` can be changed by overwriting `apiResponse`).
///
/// For example,
/// ```json
/// // /test/api/user.json
/// {
///   'user': {
///     'name' : 'Thomas'
///   }
/// }
/// ```
class StubOfflineFirstWithRest {
  /// The prefix for all endpoints. For example, `http://0.0.0.0:3000/api`
  /// in `http://0.0.0.0:3000/api`. This is equivalent to `RestProvider#baseEndpoint`.
  final String baseEndpoint;

  /// All reponses to return from an endpoint. For example, `user/1` or `users?limit=20&offset=1`.
  /// Automatically prefixed with `$baseEndpoint/`.
  ///
  /// Responses can be either a file path or a custom response.
  ///
  /// For files, the path is **relative to the top-level /test directory** containing stub data
  /// and must end in `.json`. For example, `api/user.json` in `my-app/test/api/user.json`
  ///
  /// For custom responses, the return value will be **exact**. This class will not attempt to
  /// decode JSON for a custom response; it's recommended to submit a `Map` instead for
  /// JSON responses.
  final Iterable<StubOfflineFirstRestResponse> responses;

  /// Create a client to use with [RestProvider] that responds to endpoints
  /// with predefined responses.
  MockClient get client => MockClient((req) async {
        final statusCode = _statusCodeForMethod(req.method);
        final reqMethodToEnum = _stubHttpEnumFromMethod(req.method);

        final response = responses.firstWhereOrNull((e) {
          final methodMatches = e.method == reqMethodToEnum || e.method == StubHttpMethod.any;
          final urlMatches = req.url == Uri.parse('$baseEndpoint/${e.endpoint}');
          return methodMatches && urlMatches;
        });
        if (response != null) {
          return http.Response(response.response, statusCode);
        }

        return http.Response('endpoint ${req.method} ${req.url} is not stubbed', 422);
      });

  /// Generate mocks for an [OfflineFirstWithRestModel]. Instantiation automatically stubs REST responses.
  ///
  /// For convenience, your data structure only needs to be defined once. Include a sample API
  /// response in a sibling `/api/` directory (`api` can be changed by overwriting `apiResponse`).
  StubOfflineFirstWithRest({
    required this.baseEndpoint,
    required this.responses,
  });

  /// Provide a list of responses from a list of endpoints, for example:
  /// ```dart
  /// {
  ///   'my-endpoint': 'my-endpoint.json'
  /// }
  /// ```
  ///
  /// Responses will be returned on all HTTP methods. The [endpointsAndFilePaths] is
  /// **relative to the top-level /test directory**.
  factory StubOfflineFirstWithRest.fromFiles(
    String baseEndpoint,
    Map<String, String> endpointsAndFilePaths,
  ) {
    final responses = endpointsAndFilePaths.entries.map((entry) {
      return StubOfflineFirstRestResponse.fromFile(entry.value, endpoint: entry.key);
    }).toList();

    return StubOfflineFirstWithRest(responses: responses, baseEndpoint: baseEndpoint);
  }
}

int _statusCodeForMethod(String method) {
  switch (method) {
    case 'GET':
      return 200;
    case 'POST':
      return 201;
    case 'DELETE':
      return 204;
    default:
      return 422;
  }
}

StubHttpMethod _stubHttpEnumFromMethod(String httpMethod) {
  switch (httpMethod) {
    case 'GET':
      return StubHttpMethod.get;
    case 'PUT':
      return StubHttpMethod.put;
    case 'POST':
      return StubHttpMethod.post;
    case 'DELETE':
      return StubHttpMethod.delete;
    default:
      return StubHttpMethod.any;
  }
}
