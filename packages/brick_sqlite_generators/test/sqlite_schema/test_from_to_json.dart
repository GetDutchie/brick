import 'package:brick_sqlite_abstract/annotations.dart';

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite_abstract/db.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{};

/// A consumable database structure including the latest generated migration.
final schema = Schema(0, generatorVersion: 1, tables: <SchemaTable>{
  SchemaTable('AllFieldTypes', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('assoc', Column.varchar)
  }, indices: <SchemaIndex>{})
});
''';

/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SqliteSerializable()
class AllFieldTypes {
  AllFieldTypes({
    this.assoc,
  });

  final ToFromJsonAssoc? assoc;
}

class ToFromJsonAssoc {
  final int? integer;

  ToFromJsonAssoc({
    this.integer,
  });

  String toJson() => integer.toString();

  factory ToFromJsonAssoc.fromJson(String data) => ToFromJsonAssoc(integer: int.tryParse(data));
}
