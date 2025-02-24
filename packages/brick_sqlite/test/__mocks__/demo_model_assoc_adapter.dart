import 'package:brick_core/src/model_repository.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
// ignore: unused_import, unused_shown_name
import 'package:brick_sqlite/db.dart';
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import 'demo_model.dart';

Future<DemoModelAssoc> _$DemoModelAssocFromSqlite(
  Map<String, dynamic> data, {
  SqliteProvider? provider,
  repository,
}) async =>
    DemoModelAssoc(name: data['full_name'] == null ? null : data['full_name'] as String)
      ..primaryKey = data['_brick_id'] as int;

Future<Map<String, dynamic>> _$DemoModelAssocToSqlite(
  DemoModelAssoc instance, {
  SqliteProvider? provider,
  repository,
}) async =>
    {'full_name': instance.name};

/// Construct a [DemoModelAssoc]
class DemoModelAssocAdapter extends SqliteAdapter<DemoModelAssoc> {
  DemoModelAssocAdapter();

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
  };

  @override
  Future<int?> primaryKeyByUniqueColumns(
    DemoModelAssoc instance,
    DatabaseExecutor executor,
  ) async =>
      instance.primaryKey;

  @override
  final tableName = 'DemoModelAssoc';

  @override
  Future<DemoModelAssoc> fromSqlite(
    Map<String, dynamic> input, {
    required SqliteProvider<SqliteModel> provider,
    ModelRepository<SqliteModel>? repository,
  }) async =>
      await _$DemoModelAssocFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(
    DemoModelAssoc input, {
    required SqliteProvider<SqliteModel> provider,
    ModelRepository<SqliteModel>? repository,
  }) async =>
      await _$DemoModelAssocToSqlite(input, provider: provider, repository: repository);
}
