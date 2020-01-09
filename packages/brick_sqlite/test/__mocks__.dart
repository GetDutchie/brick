import 'package:brick_sqlite_abstract/db.dart' show InsertTable;
import 'package:brick_sqlite/sqlite.dart';

const sqliteTableName = "DemoModel";

class DemoModelAssoc extends SqliteModel {
  DemoModelAssoc(this.name);
  final String name;
}

class DemoModel extends SqliteModel {
  DemoModel(this.name);
  final String name;
}

class DemoModelAdapter with SqliteAdapter<DemoModel> {
  DemoModelAdapter();
  final tableName = sqliteTableName;

  Future<DemoModel> fromSqlite(map, {provider, repository}) {
    final composedModel = DemoModel(map['name'])..primaryKey = map[InsertTable.PRIMARY_KEY_COLUMN];
    return Future.value(composedModel);
  }

  final fieldsToSqliteColumns = {
    InsertTable.PRIMARY_KEY_FIELD: {'name': InsertTable.PRIMARY_KEY_COLUMN, 'type': int},
    'id': {'name': 'id', 'type': int, 'iterable': false, 'association': false},
    'name': {'name': 'name', 'type': String, 'iterable': false, 'association': false},
    'assoc': {
      'name': 'assoc_DemoModelAssoc_brick_id',
      'type': DemoModelAssoc,
      'iterable': false,
      'association': true
    },
    'manyAssoc': {
      'name': 'many_assoc',
      'type': DemoModelAssoc,
      'iterable': true,
      'association': true
    },
    'complexFieldName': {
      'name': 'complex_field_name',
      'type': String,
      'iterable': false,
      'association': false
    }
  };

  Future<Map<String, dynamic>> toSqlite(instance, {provider, repository}) {
    return Future.value({'name': instance.name});
  }

  primaryKeyByUniqueColumns(instance, db, {provider, repository}) => null;
}

class DemoModelAssocAdapter extends DemoModelAdapter {
  DemoModelAssocAdapter();
  final tableName = sqliteTableName + "Assoc";
}

final Map<Type, SqliteAdapter<SqliteModel>> _mappings = {
  DemoModel: DemoModelAdapter(),
  DemoModelAssoc: DemoModelAssocAdapter(),
};
final dictionary = SqliteModelDictionary(_mappings);
