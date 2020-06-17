import 'package:brick_rest/rest.dart';
import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:brick_sqlite/sqlite.dart';

import 'package:brick_offline_first/offline_first.dart';
import 'package:sqflite_common/sqlite_api.dart';

class Mounty extends OfflineFirstWithRestModel {
  final String name;

  Mounty({
    this.name,
  });
}

class Horse extends OfflineFirstWithRestModel {
  final String name;

  final List<Mounty> mounties;

  Horse({
    this.name,
    this.mounties,
  });
}

Future<Mounty> _$MountyFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstWithRestRepository repository}) async {
  return Mounty(name: data['name'] as String);
}

Future<Map<String, dynamic>> _$MountyToRest(Mounty instance,
    {RestProvider provider, OfflineFirstWithRestRepository repository}) async {
  return {
    'name': instance.name,
  };
}

Future<Mounty> _$MountyFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstWithRestRepository repository}) async {
  return Mounty(name: data['name'] == null ? null : data['name'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$MountyToSqlite(Mounty instance,
    {SqliteProvider provider, OfflineFirstWithRestRepository repository}) async {
  return {
    'name': instance.name,
  };
}

/// Construct a [Mounty]
class MountyAdapter extends OfflineFirstWithRestAdapter<Mounty> {
  MountyAdapter();

  final String fromKey = null;
  final String toKey = null;
  final Map<String, Map<String, dynamic>> fieldsToSqliteColumns = {
    'primaryKey': {
      'name': '_brick_id',
      'type': int,
      'iterable': false,
      'association': false,
    },
    'name': {
      'name': 'name',
      'type': String,
      'iterable': false,
      'association': false,
    },
  };
  Future<int> primaryKeyByUniqueColumns(Mounty instance, DatabaseExecutor executor) async => null;
  final String tableName = 'Mounty';
  String restEndpoint({query, instance}) => '/mounties';

  Future<Mounty> fromRest(Map<String, dynamic> input, {provider, repository}) async =>
      await _$MountyFromRest(input, provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(Mounty input, {provider, repository}) async =>
      await _$MountyToRest(input, provider: provider, repository: repository);
  Future<Mounty> fromSqlite(Map<String, dynamic> input, {provider, repository}) async =>
      await _$MountyFromSqlite(input, provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(Mounty input, {provider, repository}) async =>
      await _$MountyToSqlite(input, provider: provider, repository: repository);
}

Future<Horse> _$HorseFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstWithRestRepository repository}) async {
  return Horse(
      name: data['name'] as String,
      mounties: await Future.wait<Mounty>(data['mounties']
              ?.map((d) => MountyAdapter().fromRest(d, provider: provider, repository: repository))
              ?.toList()
              ?.cast<Future<Mounty>>() ??
          []));
}

Future<Map<String, dynamic>> _$HorseToRest(Horse instance,
    {RestProvider provider, OfflineFirstWithRestRepository repository}) async {
  return {
    'name': instance.name,
    'mounties': await Future.wait<Map<String, dynamic>>(
        instance.mounties?.map((s) => MountyAdapter().toRest(s))?.toList() ?? [])
  };
}

Future<Horse> _$HorseFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstWithRestRepository repository}) async {
  return Horse(
      name: data['name'] == null ? null : data['name'] as String,
      mounties: (await provider?.rawQuery(
              'SELECT `Mounty_brick_id` FROM `_brick_Horse_mounties` WHERE Horse_brick_id = ?',
              [data['_brick_id'] as int])?.then((results) {
        final ids = results.map((r) => (r ?? {})['Mounty_brick_id']);
        return Future.wait<Mounty>(ids.map((primaryKey) => repository
            ?.getAssociation<Mounty>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
      }))
          ?.toList()
          ?.cast<Mounty>())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$HorseToSqlite(Horse instance,
    {SqliteProvider provider, OfflineFirstWithRestRepository repository}) async {
  return {'name': instance.name};
}

/// Construct a [Horse]
class HorseAdapter extends OfflineFirstWithRestAdapter<Horse> {
  HorseAdapter();

  String restEndpoint({query, instance}) => '';
  final String fromKey = null;
  final String toKey = null;
  final Map<String, Map<String, dynamic>> fieldsToSqliteColumns = {
    'primaryKey': {
      'name': '_brick_id',
      'type': int,
      'iterable': false,
      'association': false,
    },
    'name': {
      'name': 'name',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'mounties': {
      'name': 'mounties',
      'type': Mounty,
      'iterable': true,
      'association': true,
    }
  };
  Future<int> primaryKeyByUniqueColumns(Horse instance, DatabaseExecutor executor) async => null;
  final String tableName = 'Horse';
  Future<void> afterSave(instance, {provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int>(instance.mounties?.map((s) async {
        final id = s?.primaryKey ?? await provider?.upsert<Mounty>(s, repository: repository);
        return await provider?.rawInsert(
            'INSERT OR REPLACE INTO `_brick_Horse_mounties` (`Horse_brick_id`, `Mounty_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }
  }

  Future<Horse> fromRest(Map<String, dynamic> input, {provider, repository}) async =>
      await _$HorseFromRest(input, provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(Horse input, {provider, repository}) async =>
      await _$HorseToRest(input, provider: provider, repository: repository);
  Future<Horse> fromSqlite(Map<String, dynamic> input, {provider, repository}) async =>
      await _$HorseFromSqlite(input, provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(Horse input, {provider, repository}) async =>
      await _$HorseToSqlite(input, provider: provider, repository: repository);
}
