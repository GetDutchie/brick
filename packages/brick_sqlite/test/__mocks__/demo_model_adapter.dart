import 'demo_model.dart';
// ignore: unused_import, unused_shown_name
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite/sqlite.dart';
import 'package:brick_core/core.dart' show Query;
import 'package:sqflite/sqflite.dart' show DatabaseExecutor;

Future<DemoModel> _$DemoModelFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, repository}) async {
  return DemoModel(
      name: data['name'] == null ? null : data['name'] as String,
      assoc: data['assoc_DemoModelAssoc_brick_id'] == null
          ? null
          : (data['assoc_DemoModelAssoc_brick_id'] > -1
              ? (await repository?.getAssociation<DemoModelAssoc>(
                  Query.where('primaryKey', data['assoc_DemoModelAssoc_brick_id'] as int,
                      limit1: true),
                ))
                  ?.first
              : null),
      complexFieldName:
          data['complex_field_name'] == null ? null : data['complex_field_name'] as String,
      lastName: data['last_name'] == null ? null : data['last_name'] as String,
      manyAssoc: (await provider?.rawQuery(
              'SELECT DISTINCT `f_DemoModelAssoc_brick_id` FROM `_brick_DemoModel_many_assoc` WHERE l_DemoModel_brick_id = ?',
              [data['_brick_id'] as int])?.then((results) {
        final ids = results.map((r) => (r ?? {})['f_DemoModelAssoc_brick_id']);
        return Future.wait<DemoModelAssoc>(ids.map((primaryKey) => repository
            ?.getAssociation<DemoModelAssoc>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
      }))
          ?.toList()
          ?.cast<DemoModelAssoc>(),
      simpleBool: data['simple_bool'] == null ? null : data['simple_bool'] == 1)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$DemoModelToSqlite(DemoModel instance,
    {SqliteProvider provider, repository}) async {
  return {
    'assoc_DemoModelAssoc_brick_id': instance.assoc?.primaryKey ??
        await provider?.upsert<DemoModelAssoc>(instance.assoc, repository: repository),
    'complex_field_name': instance.complexFieldName,
    'last_name': instance.lastName,
    'name': instance.name,
    'simple_bool': instance.simpleBool == null ? null : (instance.simpleBool ? 1 : 0)
  };
}

/// Construct a [DemoModel]
class DemoModelAdapter extends SqliteAdapter<DemoModel> {
  DemoModelAdapter();

  final String fromKey = null;
  final String toKey = null;
  @override
  final Map<String, SqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': SqliteColumnDefinition(
      association: false,
      iterable: false,
      name: '_brick_id',
      type: int,
    ),
    'someField': SqliteColumnDefinition(
      association: false,
      iterable: false,
      name: 'some_field',
      type: bool,
    ),
    'assoc': SqliteColumnDefinition(
      association: true,
      iterable: false,
      name: 'assoc_DemoModelAssoc_brick_id',
      type: DemoModelAssoc,
    ),
    'complexFieldName': SqliteColumnDefinition(
      association: false,
      iterable: false,
      name: 'complex_field_name',
      type: String,
    ),
    'lastName': SqliteColumnDefinition(
      association: false,
      iterable: false,
      name: 'last_name',
      type: String,
    ),
    'manyAssoc': SqliteColumnDefinition(
      association: true,
      iterable: true,
      name: 'many_assoc',
      type: DemoModelAssoc,
    ),
    'name': SqliteColumnDefinition(
      association: false,
      iterable: false,
      name: 'name',
      type: String,
    ),
    'simpleBool': SqliteColumnDefinition(
      association: false,
      iterable: false,
      name: 'simple_bool',
      type: bool,
    ),
  };
  @override
  Future<int> primaryKeyByUniqueColumns(DemoModel instance, DatabaseExecutor executor) async =>
      instance.primaryKey;

  @override
  final String tableName = 'DemoModel';
  @override
  Future<void> afterSave(instance, {provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int>(instance.manyAssoc?.map((s) async {
            final id =
                s?.primaryKey ?? await provider?.upsert<DemoModelAssoc>(s, repository: repository);
            return await provider?.rawInsert(
                'INSERT OR IGNORE INTO `_brick_DemoModel_many_assoc` (`l_DemoModel_brick_id`, `f_DemoModelAssoc_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id]);
          }) ??
          []);
    }
  }

  @override
  Future<DemoModel> fromSqlite(Map<String, dynamic> input, {provider, repository}) async =>
      await _$DemoModelFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(DemoModel input, {provider, repository}) async =>
      await _$DemoModelToSqlite(input, provider: provider, repository: repository);
}
