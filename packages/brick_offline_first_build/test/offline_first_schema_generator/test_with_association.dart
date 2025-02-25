import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithRest()
class SqliteAssoc extends OfflineFirstWithRestModel {
  @Sqlite(ignore: true)
  final int key = -1;
}

const output = '''
// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{};

/// A consumable database structure including the latest generated migration.
final schema = Schema(
  0,
  generatorVersion: 1,
  tables: <SchemaTable>{
    SchemaTable(
      'SqliteAssoc',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
      },
      indices: <SchemaIndex>{},
    ),
    SchemaTable(
      'OneToOneAssocation',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn(
          'assoc_SqliteAssoc_brick_id',
          Column.integer,
          isForeignKey: true,
          foreignTableName: 'SqliteAssoc',
          onDeleteCascade: false,
          onDeleteSetDefault: false,
        ),
        SchemaColumn(
          'assoc2_SqliteAssoc_brick_id',
          Column.integer,
          isForeignKey: true,
          foreignTableName: 'SqliteAssoc',
          onDeleteCascade: false,
          onDeleteSetDefault: false,
        ),
      },
      indices: <SchemaIndex>{},
    ),
  },
);
''';

@ConnectOfflineFirstWithRest()
class OneToOneAssocation extends OfflineFirstWithRestModel {
  final SqliteAssoc? assoc;
  final SqliteAssoc? assoc2;

  OneToOneAssocation({this.assoc, this.assoc2});
}
