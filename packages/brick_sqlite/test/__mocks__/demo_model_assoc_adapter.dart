import 'demo_model.dart';
// ignore: unused_import, unused_shown_name
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite/sqlite.dart';
import 'package:sqflite/sqflite.dart' show DatabaseExecutor;

Future<DemoModelAssoc> _$DemoModelAssocFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, repository}) async {
  return DemoModelAssoc(name: data['name'] == null ? null : data['name'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$DemoModelAssocToSqlite(DemoModelAssoc instance,
    {SqliteProvider provider, repository}) async {
  return {'name': instance.name};
}

/// Construct a [DemoModelAssoc]
class DemoModelAssocAdapter extends SqliteAdapter<DemoModelAssoc> {
  DemoModelAssocAdapter();

  String restEndpoint({query, instance}) {
    return null;
  }

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
    'name': SqliteColumnDefinition(
      association: false,
      iterable: false,
      name: 'name',
      type: String,
    ),
  };

  @override
  Future<int> primaryKeyByUniqueColumns(DemoModelAssoc instance, DatabaseExecutor executor) async =>
      instance?.primaryKey;

  @override
  final String tableName = 'DemoModelAssoc';

  @override
  Future<DemoModelAssoc> fromSqlite(Map<String, dynamic> input, {provider, repository}) async =>
      await _$DemoModelAssocFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(DemoModelAssoc input, {provider, repository}) async =>
      await _$DemoModelAssocToSqlite(input, provider: provider, repository: repository);
}
