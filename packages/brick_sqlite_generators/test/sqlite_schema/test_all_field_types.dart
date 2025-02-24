import 'package:brick_sqlite/brick_sqlite.dart';

enum Casing { snake, camel }

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
      'AllFieldTypes',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('integer', Column.integer),
        SchemaColumn('boolean', Column.boolean),
        SchemaColumn('dub', Column.Double),
        SchemaColumn('string', Column.varchar),
        SchemaColumn('list', Column.varchar),
        SchemaColumn('longer_camelized_variable', Column.varchar),
        SchemaColumn('casing', Column.integer),
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
class AllFieldTypes {
  AllFieldTypes({
    this.integer,
    this.boolean,
    this.dub,
    this.string,
    this.list,
    this.longerCamelizedVariable,
    this.casing,
  });

  final int? integer;
  final bool? boolean;
  final double? dub;
  final String? string;
  final List<int>? list;
  final String? longerCamelizedVariable;
  final Casing? casing;
}
