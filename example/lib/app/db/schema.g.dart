// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite_abstract/db.dart';
// ignore: unused_import
import 'package:brick_sqlite_abstract/db.dart' show Migratable;
part '20200120200549.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final Set<Migration> migrations = Set.from([Migration20200120200549()]);

/// A consumable database structure including the latest generated migration.
final schema = Schema(20200120200549,
    generatorVersion: 1,
    tables: Set<SchemaTable>.from([
      SchemaTable("Customer",
          columns: Set.from([
            SchemaColumn("_brick_id", int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn("id", int, unique: true),
            SchemaColumn("first_name", String),
            SchemaColumn("last_name", String),
            SchemaColumn("pizzas", String)
          ])),
      SchemaTable("Pizza",
          columns: Set.from([
            SchemaColumn("_brick_id", int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn("id", int, unique: true),
            SchemaColumn("toppings", String),
            SchemaColumn("customer_Customer_brick_id", int,
                isForeignKey: true, foreignTableName: "Customer"),
            SchemaColumn("frozen", bool)
          ]))
    ]));
