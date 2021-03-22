import 'demo_model.dart';
// ignore: unused_import, unused_shown_name
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite/sqlite.dart';
import 'package:sqflite/sqflite.dart' show DatabaseExecutor;

Future<DemoModelAssoc> _$DemoModelAssocFromSqlite(Map<String, dynamic> data,
    {SqliteProvider? provider, repository}) async {
  return DemoModelAssoc(name: data['full_name'] == null ? null : data['full_name'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$DemoModelAssocToSqlite(DemoModelAssoc instance,
    {SqliteProvider? provider, repository}) async {
  return {'full_name': instance.name};
}

/// Construct a [DemoModelAssoc]
class DemoModelAssocAdapter extends SqliteAdapter<DemoModelAssoc> {
  DemoModelAssocAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'id': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id',
      iterable: false,
      type: int,
    ),
    'someField': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'some_field',
      iterable: false,
      type: bool,
    ),
    'assoc': RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'assoc_DemoModelAssoc_brick_id',
      iterable: false,
      type: DemoModelAssoc,
    ),
    'complexFieldName': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'complex_field_name',
      iterable: false,
      type: String,
    ),
    'lastName': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_name',
      iterable: false,
      type: String,
    ),
    'manyAssoc': RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'many_assoc',
      iterable: true,
      type: DemoModelAssoc,
    ),
    'name': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'full_name',
      iterable: false,
      type: String,
    ),
    'simpleBool': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'simple_bool',
      iterable: false,
      type: bool,
    ),
  };

  @override
  Future<int?> primaryKeyByUniqueColumns(
          DemoModelAssoc instance, DatabaseExecutor executor) async =>
      instance.primaryKey;

  @override
  final String tableName = 'DemoModelAssoc';

  @override
  Future<DemoModelAssoc> fromSqlite(Map<String, dynamic> input,
          {required provider, repository}) async =>
      await _$DemoModelAssocFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(DemoModelAssoc input,
          {required provider, repository}) async =>
      await _$DemoModelAssocToSqlite(input, provider: provider, repository: repository);
}
