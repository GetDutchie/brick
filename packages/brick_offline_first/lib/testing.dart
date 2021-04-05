import 'dart:io';

import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:collection/collection.dart';

enum StubHttpMethod { get, post, put, delete, any }

class StubOfflineFirstWithRestResponse {
  /// Limit this [response] to only return for a specific HTTP method;
  /// defaults to `any`, meaning the [response] will be returned regardless
  /// of the request.
  final StubHttpMethod method;

  /// The text returned from the HTTP request.
  final String response;

  static String get currentDirectory {
    final directory = p.dirname(Platform.script.path);
    // when running this script from the project (i.e. `flutter test`),
    // the directory is where main.dart lives. We want the test directory.
    if (directory.contains('/test')) {
      return directory;
    }

    return p.join(directory, 'test');
  }

  StubOfflineFirstWithRestResponse(
    this.response, {
    StubHttpMethod? method,
  }) : method = method ?? StubHttpMethod.any;

  factory StubOfflineFirstWithRestResponse.fromFile(String filePath, {StubHttpMethod? method}) {
    final apiFile = File(p.join(currentDirectory, filePath));
    return StubOfflineFirstWithRestResponse(apiFile.readAsStringSync(), method: method);
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
class StubOfflineFirstWithRestModel {
  /// All reponses to return from an endpoint. For example, `user/1` or `users?limit=20&offset=1`.
  /// Automatically prefixed with `$baseUrl/`.
  ///
  /// Responses can be either a file path or a custom response.
  ///
  /// For files, the path is **relative to the top-level /test directory** containing stub data
  /// and must end in `.json`. For example, `api/user.json` in `my-app/test/api/user.json`
  ///
  /// For custom responses, the return value will be **exact**. This class will not attempt to
  /// decode JSON for a custom response; it's recommended to submit a `Map` instead for
  /// JSON responses.
  final Map<String, List<StubOfflineFirstWithRestResponse>> apiResponses;

  StubOfflineFirstWithRestModel({
    required this.apiResponses,
  });

  /// Responses will be returned on all HTTP methods. The [filePath] is
  /// **relative to the top-level /test directory**.
  factory StubOfflineFirstWithRestModel.fromFile(String endpoint, String filePath) {
    return StubOfflineFirstWithRestModel(apiResponses: {
      endpoint: [StubOfflineFirstWithRestResponse.fromFile(filePath)]
    });
  }

  /// Provide a list of responses from a list of endpoints, for example:
  /// ```dart
  /// {
  ///   'my-endpoint': 'my-endpoint.json'
  /// }
  /// ```
  ///
  /// Responses will be returned on all HTTP methods. The [filePath] is
  /// **relative to the top-level /test directory**.
  static List<StubOfflineFirstWithRestModel> fromFiles(Map<String, String> endpointsAndFilePaths) {
    return endpointsAndFilePaths.entries.map((entry) {
      return StubOfflineFirstWithRestModel.fromFile(entry.key, entry.value);
    }).toList();
  }
}

/// Create a client to use with [RestProvider] that responds to endpoints
/// with predefined responses.
MockClient stubRestClient(String baseUrl, List<StubOfflineFirstWithRestModel> modelStubs) {
  return MockClient((req) async {
    final statusCode = _statusCodeForMethod(req.method);
    final reqMethodToEnum = _stubHttpEnumFromMethod(req.method);

    for (final modelStub in modelStubs) {
      for (final endpoint in modelStub.apiResponses.keys) {
        if (req.url == Uri.parse('$baseUrl/$endpoint')) {
          final response = modelStub.apiResponses[endpoint]!.firstWhereOrNull(
              (e) => e.method == reqMethodToEnum || e.method == StubHttpMethod.any);
          if (response != null) {
            return http.Response(response.response, statusCode);
          }
        }
      }
    }

    return http.Response('endpoint ${req.method} ${req.url} is not stubbed', 422);
  });
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
