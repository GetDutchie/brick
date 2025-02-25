import 'package:brick_sqlite/brick_sqlite.dart';

/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SqliteSerializable()
class SqliteAssoc extends SqliteModel {
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
      '_brick_OneToManyAssocation_assoc',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn(
          'l_OneToManyAssocation_brick_id',
          Column.integer,
          isForeignKey: true,
          foreignTableName: 'OneToManyAssocation',
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
          columns: ['l_OneToManyAssocation_brick_id', 'f_SqliteAssoc_brick_id'],
          unique: true,
        ),
      },
    ),
    SchemaTable(
      'OneToManyAssocation',
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
  },
);
''';

/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SqliteSerializable()
class OneToManyAssocation extends SqliteModel {
  final List<SqliteAssoc>? assoc;

  OneToManyAssocation({this.assoc});
}
