import 'dart:io';

import 'package:brick_rest/rest.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:brick_sqlite/sqlite.dart';
import 'package:brick_offline_first/testing.dart' hide MockClient;

import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_offline_first/offline_first.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

export 'package:brick_offline_first/offline_first.dart';
export '../__helpers__.dart';

class MockClient extends Mock implements http.Client {}

class DemoModel extends OfflineFirstWithRestModel {
  DemoModel(this.name);

  final String name;

  toString() => "$name$primaryKey";

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DemoModel && this?.name == other?.name;

  @override
  int get hashCode => name.hashCode;
}

/// The exact same as [DemoModel], except this class is tracked by the Memory Cache Provider
/// while [DemoModel] is not.
class MemoryDemoModel extends DemoModel {
  MemoryDemoModel(String name) : super(name);
}

class DemoModelAdapter extends OfflineFirstWithRestAdapter<DemoModel> {
  final String fromKey = null;
  final String toKey = null;
  DemoModel fromMap(map) => DemoModel(map['name']);
  Map<String, dynamic> toMap(DemoModel input) => {'name': input.name};

  fromRest(data, {provider, repository}) => Future.value(fromMap(data));
  toRest(input, {provider, repository}) => Future.value(toMap(input));
  final tableName = 'Demo';
  restEndpoint({query, instance}) => '/people';
  primaryKeyByUniqueColumns(instance, db, {provider, repository}) => null;

  Future<DemoModel> fromSqlite(map, {provider, repository}) {
    final composedModel = DemoModel(map['name'])..primaryKey = map[InsertTable.PRIMARY_KEY_COLUMN];
    return Future.value(composedModel);
  }

  Future<Map<String, dynamic>> toSqlite(instance, {provider, repository}) {
    return Future.value({'name': instance.name});
  }
}

class TestRepository extends OfflineFirstWithRestRepository {
  static TestRepository _singleton;
  final migrationManager = null;
  final isConnected = true;

  TestRepository._(
    RestProvider _restProvider,
    SqliteProvider _sqliteProvider,
  ) : super(
          restProvider: _restProvider,
          sqliteProvider: _sqliteProvider,
          memoryCacheProvider: MemoryCacheProvider([MemoryDemoModel]),
        );
  factory TestRepository() => _singleton;

  factory TestRepository.createInstance({
    String baseUrl,
    String dbName,
    RestModelDictionary restDictionary,
    SqliteModelDictionary sqliteDictionary,
    http.Client client,
  }) {
    return TestRepository._(
      RestProvider(baseUrl, modelDictionary: restDictionary, client: client),
      SqliteProvider(dbName, modelDictionary: sqliteDictionary),
    );
  }

  static TestRepository configure({
    String baseUrl,
    String dbName,
    RestModelDictionary restDictionary,
    SqliteModelDictionary sqliteDictionary,
    http.Client client,
  }) {
    _singleton = TestRepository.createInstance(
      baseUrl: baseUrl,
      dbName: dbName,
      restDictionary: restDictionary,
      sqliteDictionary: sqliteDictionary,
      client: client,
    );
    return _singleton;
  }
}

final _mappings = {
  DemoModel: DemoModelAdapter(),
  MemoryDemoModel: DemoModelAdapter(),
};
final restDictiontary = RestModelDictionary(_mappings);
final sqliteDictionary = SqliteModelDictionary(_mappings);
