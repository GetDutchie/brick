import 'dart:io';

import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:path/path.dart' as p;

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
  final Map<String, String> apiResponses;

  String get currentDirectory {
    final directory = p.dirname(Platform.script.path);
    // when running this script from the project (i.e. `flutter test`),
    // the directory is where main.dart lives. We want the test directory.
    if (directory.contains('/test')) {
      return directory;
    }

    return p.join(directory, 'test');
  }

  StubOfflineFirstWithRestModel({
    required this.apiResponses,
  });

  /// Load sample API response from preloaded JSON files
  String _parseResponse(dynamic customResponse) {
    if (customResponse is String && customResponse.endsWith('.json')) {
      final apiFile = File(p.join(currentDirectory, customResponse));
      return apiFile.readAsStringSync();
    }

    return customResponse;
  }

  String responseForEndpoint(String endpoint) {
    return _parseResponse(apiResponses[endpoint]);
  }
}
