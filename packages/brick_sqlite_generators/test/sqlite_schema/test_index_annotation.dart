import 'package:brick_sqlite/brick_sqlite.dart';

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
      'IndexAnnotation',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('non_unique', Column.varchar),
        SchemaColumn('unique', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['non_unique'], unique: false),
        SchemaIndex(columns: ['unique'], unique: true),
      },
    ),
  },
);
''';

/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SqliteSerializable()
class IndexAnnotation extends SqliteModel {
  @Sqlite(index: true)
  final String? nonUnique;

  @Sqlite(index: true, unique: true)
  final String? unique;

  IndexAnnotation({this.nonUnique, this.unique});
}
