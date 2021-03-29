import 'package:brick_core/core.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:brick_sqlite/sqlite.dart';

import 'package:brick_offline_first/offline_first.dart';
import 'package:sqflite_common/sqlite_api.dart';

class Mounty extends OfflineFirstWithRestModel {
  final String? name;

  Mounty({
    this.name,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is Mounty && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class Horse extends OfflineFirstWithRestModel {
  final String? name;

  final List<Mounty?> mounties;

  Horse({
    this.name,
    this.mounties = const <Mounty>[],
  });
}

Future<Mounty> _$MountyFromRest(Map<String, dynamic> data,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Mounty(name: data['name'] as String);
}

Future<Map<String, dynamic>> _$MountyToRest(Mounty instance,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return {
    'name': instance.name,
  };
}

Future<Mounty> _$MountyFromSqlite(Map<String, dynamic> data,
    {SqliteProvider? provider, OfflineFirstWithRestRepository? repository}) async {
  return Mounty(name: data['name'] == null ? null : data['name'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$MountyToSqlite(Mounty instance,
    {SqliteProvider? provider, OfflineFirstWithRestRepository? repository}) async {
  return {
    'name': instance.name,
  };
}

/// Construct a [Mounty]
class MountyAdapter extends OfflineFirstWithRestAdapter<Mounty> {
  MountyAdapter();

  @override
  final String? fromKey = null;
  @override
  final String? toKey = null;
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': RuntimeSqliteColumnDefinition(
      columnName: '_brick_id',
      type: int,
      iterable: false,
      association: false,
    ),
    'name': RuntimeSqliteColumnDefinition(
      columnName: 'name',
      type: String,
      iterable: false,
      association: false,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Mounty instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'Mounty';
  @override
  String restEndpoint({query, instance}) => '/mounties';
  @override
  Future<Mounty> fromRest(Map<String, dynamic> input, {required provider, repository}) async =>
      await _$MountyFromRest(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(Mounty input, {required provider, repository}) async =>
      await _$MountyToRest(input, provider: provider, repository: repository);
  @override
  Future<Mounty> fromSqlite(Map<String, dynamic> input, {required provider, repository}) async =>
      await _$MountyFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Mounty input, {required provider, repository}) async =>
      await _$MountyToSqlite(input, provider: provider, repository: repository);
}

Future<Horse> _$HorseFromRest(Map<String, dynamic> data,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Horse(
      name: data['name'] as String,
      mounties: await Future.wait<Mounty>(data['mounties']
              ?.map((d) => MountyAdapter().fromRest(d, provider: provider, repository: repository))
              ?.toList()
              ?.cast<Future<Mounty>>() ??
          []));
}

Future<Map<String, dynamic>> _$HorseToRest(Horse instance,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return {
    'name': instance.name,
    'mounties': await Future.wait<Map<String, dynamic>>(instance.mounties
            .map((s) => MountyAdapter().toRest(s, provider: provider, repository: repository))
            .toList() ??
        [])
  };
}

Future<Horse> _$HorseFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Horse(
      name: data['name'] == null ? null : data['name'] as String,
      mounties: (await provider.rawQuery(
              'SELECT `f_Mounty_brick_id` FROM `_brick_Horse_mounties` WHERE l_Horse_brick_id = ?',
              [data['_brick_id'] as int]).then((results) {
        final ids = results.map((r) => r['f_Mounty_brick_id']);
        return Future.wait<Mounty?>(ids.map((primaryKey) => repository
            ?.getAssociation<Mounty>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => r?.isNotEmpty ?? false ? r!.first : null)));
      }))
          .toList()
          .cast<Mounty>())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$HorseToSqlite(Horse instance,
    {SqliteProvider? provider, OfflineFirstRepository<SqliteModel>? repository}) async {
  return {'name': instance.name};
}

/// Construct a [Horse]
class HorseAdapter extends OfflineFirstWithRestAdapter<Horse> {
  HorseAdapter();
  @override
  String restEndpoint({query, instance}) => '';
  @override
  final String? fromKey = null;
  @override
  final String? toKey = null;
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': RuntimeSqliteColumnDefinition(
      columnName: '_brick_id',
      type: int,
      iterable: false,
      association: false,
    ),
    'name': RuntimeSqliteColumnDefinition(
      columnName: 'name',
      type: String,
      iterable: false,
      association: false,
    ),
    'mounties': RuntimeSqliteColumnDefinition(
      columnName: 'mounties',
      type: Mounty,
      iterable: true,
      association: true,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Horse instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'Horse';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int?>(instance.mounties.map((s) async {
        final id = s?.primaryKey ?? await provider.upsert<Mounty>(s, repository: repository);
        return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_Horse_mounties` (`l_Horse_brick_id`, `f_Mounty_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }
  }

  @override
  Future<Horse> fromRest(Map<String, dynamic> input,
          {required provider, ModelRepository<RestModel>? repository}) async =>
      await _$HorseFromRest(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(Horse input, {required provider, repository}) async =>
      await _$HorseToRest(input, provider: provider, repository: repository);
  @override
  Future<Horse> fromSqlite(Map<String, dynamic> input, {required provider, repository}) async =>
      await _$HorseFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Horse input, {required provider, repository}) async =>
      await _$HorseToSqlite(input, provider: provider, repository: repository);
}
