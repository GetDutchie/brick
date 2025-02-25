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
      '_brick_OneToOneAssocation_assocs',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn(
          'l_OneToOneAssocation_brick_id',
          Column.integer,
          isForeignKey: true,
          foreignTableName: 'OneToOneAssocation',
          onDeleteCascade: true,
          onDeleteSetDefault: false,
        ),
        SchemaColumn(
          'f_SqliteAssoc_brick_id',
          Column.integer,
          isForeignKey: true,
          foreignTableName: 'SqliteAssoc',
          onDeleteCascade: true,
          onDeleteSetDefault: false,
        ),
      },
      indices: <SchemaIndex>{
        SchemaIndex(
          columns: ['l_OneToOneAssocation_brick_id', 'f_SqliteAssoc_brick_id'],
          unique: true,
        ),
      },
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
      },
      indices: <SchemaIndex>{},
    ),
  },
);
''';

@ConnectOfflineFirstWithRest()
class OneToOneAssocation extends OfflineFirstWithRestModel {
  final SqliteAssoc? assoc;
  final List<SqliteAssoc>? assocs;

  OneToOneAssocation({this.assoc, this.assocs});
}
