import 'package:brick_sqlite/db.dart';
import 'package:brick_sqlite/src/models/sqlite_model.dart';
import 'package:brick_sqlite/src/sqlite_adapter.dart';
import 'package:brick_sqlite/src/sqlite_model_dictionary.dart';

import '__mocks__/demo_model.dart';
import '__mocks__/demo_model_adapter.dart';
import '__mocks__/demo_model_assoc_adapter.dart';

export '__mocks__/demo_model.dart';

const _demoModelMigrationCommands = [
  InsertTable('DemoModelAssoc'),
  InsertTable('_brick_DemoModel_many_assoc'),
  InsertTable('DemoModel'),
  InsertForeignKey(
    '_brick_DemoModel_many_assoc',
    'DemoModel',
    foreignKeyColumn: 'l_DemoModel_brick_id',
    onDeleteCascade: true,
  ),
  InsertForeignKey(
    '_brick_DemoModel_many_assoc',
    'DemoModelAssoc',
    foreignKeyColumn: 'f_DemoModelAssoc_brick_id',
    onDeleteCascade: true,
  ),
  InsertForeignKey(
    'DemoModel',
    'DemoModelAssoc',
    foreignKeyColumn: 'assoc_DemoModelAssoc_brick_id',
  ),
  InsertColumn('complex_field_name', Column.varchar, onTable: 'DemoModel'),
  InsertColumn('last_name', Column.varchar, onTable: 'DemoModel'),
  InsertColumn('full_name', Column.varchar, onTable: 'DemoModel'),
  InsertColumn('full_name', Column.varchar, onTable: 'DemoModelAssoc'),
  InsertColumn('simple_bool', Column.boolean, onTable: 'DemoModel'),
  InsertColumn('simple_time', Column.varchar, onTable: 'DemoModel'),
  CreateIndex(
    columns: ['l_DemoModel_brick_id', 'f_DemoModelAssoc_brick_id'],
    onTable: '_brick_DemoModel_many_assoc',
    unique: true,
  ),
];

const _demoModelDownMigrationCommands = [
  DropTable('DemoModelAssoc'),
  DropTable('_brick_DemoModel_many_assoc'),
  DropTable('DemoModel'),
];

class DemoModelMigration extends Migration {
  const DemoModelMigration()
      : super(
          version: 2,
          up: _demoModelMigrationCommands,
          down: _demoModelDownMigrationCommands,
        );
}

final Map<Type, SqliteAdapter<SqliteModel>> _mappings = {
  DemoModel: DemoModelAdapter(),
  DemoModelAssoc: DemoModelAssocAdapter(),
};
final dictionary = SqliteModelDictionary(_mappings);
