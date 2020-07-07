import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';

/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SqliteSerializable()
class SqliteAssoc extends SqliteModel {
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
final Set<Migration> migrations = <Migration>{};

/// A consumable database structure including the latest generated migration.
final schema = Schema(0,
    generatorVersion: 1,
    tables: <SchemaTable>{
      SchemaTable('SqliteAssoc',
          columns: <SchemaColumn>{
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true)
          }),
      SchemaTable('_brick_OneToManyAssocation_assoc',
          columns: <SchemaColumn>{
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn('l_OneToManyAssocation_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'OneToManyAssocation',
                onDeleteCascade: true,
                onDeleteSetDefault: false),
            SchemaColumn('f_SqliteAssoc_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'SqliteAssoc',
                onDeleteCascade: true,
                onDeleteSetDefault: false)
          }),
      SchemaTable('OneToManyAssocation',
          columns: <SchemaColumn>{
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true)
          })
    });
''';

/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SqliteSerializable()
class OneToManyAssocation extends SqliteModel {
  final List<SqliteAssoc> assoc;

  OneToManyAssocation({this.assoc});
}
