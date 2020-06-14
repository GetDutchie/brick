import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';

@ConnectOfflineFirstWithRest()
class SqliteAssoc extends OfflineFirstWithRestModel {
  @Sqlite(ignore: true)
  final int key = -1;
}

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
      SchemaTable('SqliteAssoc',
          columns: Set.from([
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true)
          ])),
      SchemaTable('OneToOneAssocation',
          columns: Set.from([
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn('assoc_SqliteAssoc_brick_id', int,
                isForeignKey: true, foreignTableName: 'SqliteAssoc'),
            SchemaColumn('assocs', String)
          ]))
    ]));
''';

@ConnectOfflineFirstWithRest()
class OneToOneAssocation extends OfflineFirstWithRestModel {
  final SqliteAssoc assoc;
  final List<SqliteAssoc> assocs;

  OneToOneAssocation({this.assoc, this.assocs});
}
