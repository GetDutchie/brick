import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite/sqlite.dart';

const sqliteTableName = 'DemoModel';

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
  @override
  final tableName = sqliteTableName;

  @override
  Future<DemoModel> fromSqlite(map, {provider, repository}) {
    final composedModel = DemoModel(map['full_name'])
      ..primaryKey = map[InsertTable.PRIMARY_KEY_COLUMN];
    return Future.value(composedModel);
  }

  @override
  final fieldsToSqliteColumns = {
    InsertTable.PRIMARY_KEY_FIELD: {'name': InsertTable.PRIMARY_KEY_COLUMN, 'type': int},
    'id': {'name': 'id', 'type': int, 'iterable': false, 'association': false},
    'lastName': {'name': 'last_name', 'type': String, 'iterable': false, 'association': false},
    'name': {'name': 'full_name', 'type': String, 'iterable': false, 'association': false},
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
    },
    'simpleBool': {'name': 'simple_bool', 'type': bool, 'iterable': false, 'association': false},
  };

  @override
  Future<Map<String, dynamic>> toSqlite(instance, {provider, repository}) {
    return Future.value({'full_name': instance.name});
  }

  @override
  Future<int> primaryKeyByUniqueColumns(instance, db, {provider, repository}) => null;
}

const _demoModelMigrationCommands = [
  InsertTable('DemoModel'),
  InsertTable('DemoModelAssoc'),
  InsertColumn('id', Column.integer, onTable: 'DemoModel', unique: true),
  InsertColumn('simple_bool', Column.boolean, onTable: 'DemoModel'),
  InsertColumn('last_name', Column.varchar, onTable: 'DemoModel'),
  InsertColumn('full_name', Column.varchar, onTable: 'DemoModel'),
  InsertColumn('many_assoc', Column.varchar, onTable: 'DemoModel'),
  InsertForeignKey('DemoModel', 'DemoModelAssoc',
      foreignKeyColumn: 'assoc_DemoModelAssoc_brick_id'),
  InsertColumn('complex_field_name', Column.varchar, onTable: 'DemoModel'),
];

class DemoModelMigration extends Migration {
  const DemoModelMigration()
      : super(
          version: 2,
          up: _demoModelMigrationCommands,
          down: _demoModelMigrationCommands,
        );
}

class DemoModelAssocAdapter extends DemoModelAdapter {
  DemoModelAssocAdapter();
  @override
  final tableName = sqliteTableName + 'Assoc';
}

final Map<Type, SqliteAdapter<SqliteModel>> _mappings = {
  DemoModel: DemoModelAdapter(),
  DemoModelAssoc: DemoModelAssocAdapter(),
};
final dictionary = SqliteModelDictionary(_mappings);
