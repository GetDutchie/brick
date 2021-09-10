import 'dart:typed_data';

import 'package:brick_sqlite_abstract/annotations.dart';

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite_abstract/db.dart';
// ignore: unused_import
import 'package:brick_sqlite_abstract/db.dart' show Migratable;

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{};

/// A consumable database structure including the latest generated migration.
final schema = Schema(0, generatorVersion: 1, tables: <SchemaTable>{
  SchemaTable('ExplicitColumnType', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('image', Column.blob)
  }, indices: <SchemaIndex>{})
});
''';

/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SqliteSerializable()
class ExplicitColumnType {
  @Sqlite(columnType: Column.blob)
  final Uint8List? image;

  ExplicitColumnType({this.image});
}
