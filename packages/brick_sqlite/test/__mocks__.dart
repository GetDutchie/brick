import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite/sqlite.dart';
import '__mocks__/demo_model.dart';
import '__mocks__/demo_model_adapter.dart';
import '__mocks__/demo_model_assoc_adapter.dart';

export '__mocks__/demo_model.dart';

const _demoModelMigrationCommands = [
  InsertTable('DemoModelAssoc'),
  InsertTable('_brick_DemoModel_many_assoc'),
  InsertTable('DemoModel'),
  InsertForeignKey('_brick_DemoModel_many_assoc', 'DemoModel',
      foreignKeyColumn: 'l_DemoModel_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_DemoModel_many_assoc', 'DemoModelAssoc',
      foreignKeyColumn: 'f_DemoModelAssoc_brick_id',
      onDeleteCascade: true,
      onDeleteSetDefault: false),
  InsertForeignKey('DemoModel', 'DemoModelAssoc',
      foreignKeyColumn: 'assoc_DemoModelAssoc_brick_id',
      onDeleteCascade: false,
      onDeleteSetDefault: false),
  InsertColumn('complex_field_name', Column.varchar, onTable: 'DemoModel'),
  InsertColumn('last_name', Column.varchar, onTable: 'DemoModel'),
  InsertColumn('full_name', Column.varchar, onTable: 'DemoModel'),
  InsertColumn('simple_bool', Column.boolean, onTable: 'DemoModel'),
  CreateIndex(
      columns: ['l_DemoModel_brick_id', 'f_DemoModelAssoc_brick_id'],
      onTable: '_brick_DemoModel_many_assoc',
      unique: true),
];

class DemoModelMigration extends Migration {
  const DemoModelMigration()
      : super(
          version: 2,
          up: _demoModelMigrationCommands,
          down: _demoModelMigrationCommands,
        );
}

final Map<Type, SqliteAdapter<SqliteModel>> _mappings = {
  DemoModel: DemoModelAdapter(),
  DemoModelAssoc: DemoModelAssocAdapter(),
};
final dictionary = SqliteModelDictionary(_mappings);
