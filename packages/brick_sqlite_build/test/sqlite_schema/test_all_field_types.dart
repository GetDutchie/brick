import 'package:brick_offline_first_abstract/annotations.dart';

enum Casing { Snake, Camel }

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite_abstract/db.dart';
// ignore: unused_import
import 'package:brick_sqlite_abstract/db.dart' show Migratable;

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final Set<Migration> migrations = Set.from([]);

/// A consumable database structure including the latest generated migration.
final schema = Schema(0,
    generatorVersion: 1,
    tables: Set<SchemaTable>.from([
      SchemaTable("AllFieldTypes",
          columns: Set.from([
            SchemaColumn("_brick_id", int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn("integer", int),
            SchemaColumn("boolean", bool),
            SchemaColumn("dub", double),
            SchemaColumn("string", String),
            SchemaColumn("list", String),
            SchemaColumn("longer_camelized_variable", String),
            SchemaColumn("casing", int)
          ]))
    ]));
''';

@ConnectOfflineFirstWithRest()
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

  final int integer;
  final bool boolean;
  final double dub;
  final String string;
  final List<int> list;
  final String longerCamelizedVariable;
  final Casing casing;
}
