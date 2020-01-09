import 'dart:convert';
import 'dart:io';

import 'package:brick_core/core.dart';
import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// Generate mocks for an [OfflineFirstWithRestModel]. Instantiation automatically stubs REST and SQLite.
///
/// For convenience, your data structure only needs to be defined once. Include a sample API
/// response in a sibling `/api/` directory (`api` can be changed by overwriting `apiResponse`).
///
/// For example,
/// ```json
/// // /test/api/user.json
/// {
///   "user": {
///     "name" : "Thomas"
///   }
/// }
/// ```
///
/// To instantiate multiple models, use [StubOfflineFirstWithRest].
class StubOfflineFirstWithRestModel<_Model extends OfflineFirstWithRestModel> {
  OfflineFirstWithRestAdapter get adapter => modelDictionary[_model];

  /// Load sample API response from preloaded JSON files
  String get apiResponse {
    final apiFile = File(p.join(currentDirectory, filePath));
    return apiFile.readAsStringSync();
  }

  String get currentDirectory => p.dirname(Platform.script.path);

  /// Decode the JSON with the response key, if applicable
  dynamic get decodedApiResponse {
    final contents = jsonDecode(apiResponse);
    if (adapter.fromKey != null) {
      return contents[adapter.fromKey];
    } else if (contents is Map && contents?.keys?.length == 1) {
      return contents.values.first;
    } else {
      return contents;
    }
  }

  /// The relative path to the stub data.
  /// For example, `api/user.json`
  final String filePath;

  /// All endpoints to stub. For example, `user/1` or `users?limit=20&offset=1`.
  /// Automatically prefixed with `$baseUrl/`.
  final List<String> endpoints;

  final Type _model;

  Map<Type, OfflineFirstWithRestAdapter> modelDictionary;

  /// The [OfflineFirstRepository] being stubbed for this model.
  final OfflineFirstWithRestRepository repository;

  StubOfflineFirstWithRestModel({
    @required this.filePath,
    @required this.repository,
    this.endpoints = const <String>[],
    Type model,
  }) : _model = model ?? _Model {
    final dictionary = Map<Type, Adapter>();
    dictionary.addAll(repository?.remoteProvider?.modelDictionary?.adapterFor ?? {});
    dictionary.addAll(repository?.sqliteProvider?.modelDictionary?.adapterFor ?? {});
    modelDictionary = dictionary.cast<Type, OfflineFirstWithRestAdapter>();
  }

  Future<Map<String, dynamic>> buildSqliteResponseObject(Map<String, dynamic> apiObject) async {
    final fromRest = await adapter.fromRest(apiObject,
        provider: repository?.remoteProvider, repository: repository);
    return await adapter.toSqlite(fromRest,
        provider: repository?.sqliteProvider, repository: repository);
  }

  /// Generate a response equivalent to the one expected from SQFlite
  /// `Iterable`s and `Map`s are serialized as they would be by the Adapter producing the
  /// persisted data.
  Future<List<Map<String, dynamic>>> sqliteResponse() async {
    final response = decodedApiResponse;
    if (response is Map) {
      return [await buildSqliteResponseObject(response)];
    }

    final mapped = (response as List<dynamic>).map((a) => buildSqliteResponseObject(a));
    return await Future.wait(mapped);
  }
}
