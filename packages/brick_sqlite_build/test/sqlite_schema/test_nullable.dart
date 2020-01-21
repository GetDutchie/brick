import 'package:brick_sqlite_abstract/annotations.dart';
import '../__helpers__.dart';

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
      SchemaTable("Nullable",
          columns: Set.from([
            SchemaColumn("_brick_id", int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn("name", String, nullable: false)
          ]))
    ]));
''';

@ConnectAnnotation()
class Nullable {
  @Sqlite(nullable: false)
  final String name;

  Nullable({this.name});
}
