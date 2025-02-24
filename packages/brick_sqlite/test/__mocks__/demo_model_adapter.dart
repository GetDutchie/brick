import 'package:brick_core/core.dart' show Query;
import 'package:brick_core/src/model_repository.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import 'demo_model.dart';

Future<DemoModel> _$DemoModelFromSqlite(
  Map<String, dynamic> data, {
  SqliteProvider? provider,
  repository,
}) async =>
    DemoModel(
      name: data['full_name'] == null ? null : data['full_name'] as String,
      assoc: data['assoc_DemoModelAssoc_brick_id'] == null
          ? null
          : (data['assoc_DemoModelAssoc_brick_id'] > -1
              ? (await repository?.getAssociation<DemoModelAssoc>(
                  Query.where(
                    'primaryKey',
                    data['assoc_DemoModelAssoc_brick_id'] as int,
                    limit1: true,
                  ),
                ))
                  ?.first
              : null),
      complexFieldName:
          data['complex_field_name'] == null ? null : data['complex_field_name'] as String,
      lastName: data['last_name'] == null ? null : data['last_name'] as String,
      manyAssoc: (await provider?.rawQuery(
        'SELECT DISTINCT `f_DemoModelAssoc_brick_id` FROM `_brick_DemoModel_many_assoc` WHERE l_DemoModel_brick_id = ?',
        [data['_brick_id'] as int],
      ).then((results) {
        final ids = results.map((r) => r['f_DemoModelAssoc_brick_id']);
        return Future.wait<DemoModelAssoc>(
          ids.map(
            (primaryKey) => repository
                ?.getAssociation<DemoModelAssoc>(
                  Query.where('primaryKey', primaryKey, limit1: true),
                )
                ?.then((r) => (r?.isEmpty ?? true) ? null : r.first),
          ),
        );
      }))
          ?.toList(),
      simpleBool: data['simple_bool'] == null ? null : data['simple_bool'] == 1,
      simpleTime: data['simple_time'] == null
          ? null
          : data['simple_time'] == null
              ? null
              : DateTime.tryParse(data['simple_time'] as String),
    )..primaryKey = data['_brick_id'] as int;

Future<Map<String, dynamic>> _$DemoModelToSqlite(
  DemoModel instance, {
  required SqliteProvider provider,
  repository,
}) async =>
    {
      'assoc_DemoModelAssoc_brick_id': instance.assoc?.primaryKey ??
          (instance.assoc != null
              ? await provider.upsert<DemoModelAssoc>(instance.assoc!, repository: repository)
              : null),
      'complex_field_name': instance.complexFieldName,
      'last_name': instance.lastName,
      'full_name': instance.name,
      'simple_bool': instance.simpleBool == null ? null : (instance.simpleBool! ? 1 : 0),
      'simple_time': instance.simpleTime?.toIso8601String(),
    };

/// Construct a [DemoModel]
class DemoModelAdapter extends SqliteAdapter<DemoModel> {
  DemoModelAdapter();

  @override
  final fieldsToSqliteColumns = <String, RuntimeSqliteColumnDefinition>{
    'primaryKey': const RuntimeSqliteColumnDefinition(
      columnName: '_brick_id',
      type: int,
    ),
    'id': const RuntimeSqliteColumnDefinition(
      columnName: 'id',
      type: int,
    ),
    'someField': const RuntimeSqliteColumnDefinition(
      columnName: 'some_field',
      type: bool,
    ),
    'assoc': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'assoc_DemoModelAssoc_brick_id',
      type: DemoModelAssoc,
    ),
    'complexFieldName': const RuntimeSqliteColumnDefinition(
      columnName: 'complex_field_name',
      type: String,
    ),
    'lastName': const RuntimeSqliteColumnDefinition(
      columnName: 'last_name',
      type: String,
    ),
    'manyAssoc': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'many_assoc',
      iterable: true,
      type: DemoModelAssoc,
    ),
    'name': const RuntimeSqliteColumnDefinition(
      columnName: 'full_name',
      type: String,
    ),
    'simpleBool': const RuntimeSqliteColumnDefinition(
      columnName: 'simple_bool',
      type: bool,
    ),
    'simpleTime': const RuntimeSqliteColumnDefinition(
      columnName: 'simple_time',
      type: DateTime,
    ),
  };

  @override
  Future<int?> primaryKeyByUniqueColumns(DemoModel instance, DatabaseExecutor executor) async =>
      instance.primaryKey;

  @override
  final tableName = 'DemoModel';
  @override
  Future<void> afterSave(
    DemoModel instance, {
    required SqliteProvider<SqliteModel> provider,
    ModelRepository<SqliteModel>? repository,
  }) async {
    if (instance.primaryKey != null) {
      final oldColumns = await provider.rawQuery(
        'SELECT `f_DemoModelAssoc_brick_id` FROM `_brick_DemoModel_many_assoc` WHERE `l_DemoModel_brick_id` = ?',
        [instance.primaryKey],
      );
      final oldIds = oldColumns.map((a) => a['f_DemoModelAssoc_brick_id']);
      final newIds = instance.manyAssoc?.map((s) => s.primaryKey).where((s) => s != null) ?? [];
      final idsToDelete = oldIds.where((id) => !newIds.contains(id));

      await Future.wait<void>(
        idsToDelete.map(
          (id) async => await provider.rawExecute(
            'DELETE FROM `_brick_DemoModel_many_assoc` WHERE `l_DemoModel_brick_id` = ? AND `f_DemoModelAssoc_brick_id` = ?',
            [instance.primaryKey, id],
          ),
        ),
      );

      await Future.wait<int?>(
        instance.manyAssoc?.map((s) async {
              final id =
                  s.primaryKey ?? await provider.upsert<DemoModelAssoc>(s, repository: repository);
              return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_DemoModel_many_assoc` (`l_DemoModel_brick_id`, `f_DemoModelAssoc_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id],
              );
            }) ??
            [],
      );
    }
  }

  @override
  Future<DemoModel> fromSqlite(
    Map<String, dynamic> input, {
    required SqliteProvider<SqliteModel> provider,
    ModelRepository<SqliteModel>? repository,
  }) async =>
      await _$DemoModelFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(
    DemoModel input, {
    required SqliteProvider<SqliteModel> provider,
    ModelRepository<SqliteModel>? repository,
  }) async =>
      await _$DemoModelToSqlite(input, provider: provider, repository: repository);
}
