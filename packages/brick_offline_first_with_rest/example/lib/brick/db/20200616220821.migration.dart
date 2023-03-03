// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20200616220821_up = [
  InsertTable('_brick_Horse_mounties'),
  InsertTable('Horse'),
  InsertForeignKey('_brick_Horse_mounties', 'Horse',
      foreignKeyColumn: 'Horse_brick_id', onDeleteCascade: true),
  InsertForeignKey('_brick_Horse_mounties', 'Mounty',
      foreignKeyColumn: 'Mounty_brick_id', onDeleteCascade: true),
  InsertColumn('name', Column.varchar, onTable: 'Horse')
];

const List<MigrationCommand> _migration_20200616220821_down = [
  DropTable('_brick_Horse_mounties'),
  DropTable('Horse'),
  DropColumn('Horse_brick_id', onTable: '_brick_Horse_mounties'),
  DropColumn('Mounty_brick_id', onTable: '_brick_Horse_mounties'),
  DropColumn('name', onTable: 'Horse')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20200616220821',
  up: _migration_20200616220821_up,
  down: _migration_20200616220821_down,
)
class Migration20200616220821 extends Migration {
  const Migration20200616220821()
      : super(
          version: 20200616220821,
          up: _migration_20200616220821_up,
          down: _migration_20200616220821_down,
        );
}
