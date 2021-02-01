import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';
import 'package:brick_sqlite_generators/src/sqlite_schema/migration_generator.dart';
import 'package:brick_sqlite_generators/src/sqlite_fields.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart' show LibraryReader;
import 'package:dart_style/dart_style.dart' as dart_style;
import 'package:brick_sqlite_abstract/db.dart';
import 'package:source_gen/source_gen.dart';

final _formatter = dart_style.DartFormatter();
const migrationGenerator = MigrationGenerator();

/// Produces a [Schema] from all @[OfflineFirst] annotations
class SqliteSchemaGenerator {
  const SqliteSchemaGenerator();

  /// Complete schema file output
  ///
  /// [classes] are all classes by their table name with the @[OfflineFirst] annotation
  String generate(LibraryReader library, List<SqliteFields> fieldses) {
    final newSchema = _createNewSchema(library, fieldses);
    final existingMigrations = migrationGenerator.expandAllMigrations(library);

    final parts = existingMigrations.map((m) => "part '${m.version}.migration.dart';");
    final migrationClasses = existingMigrations.map((m) => 'Migration${m.version}()');

    final output = """
      // GENERATED CODE DO NOT EDIT
      // This file should be version controlled
      import 'package:brick_sqlite_abstract/db.dart';
      // ignore: unused_import
      import 'package:brick_sqlite_abstract/db.dart' show Migratable;
      ${parts.join("\n")}

      /// All intelligently-generated migrations from all `@Migratable` classes on disk
      final Set<Migration> migrations = <Migration>{ ${migrationClasses.join(",\n")} };

      /// A consumable database structure including the latest generated migration.
      final schema = ${newSchema.forGenerator};
    """;
    return _formatter.format(output);
  }

  /// Produce a migration from the difference between existing migrations and the latest schema
  String createMigration(LibraryReader library, List<SqliteFields> fieldses, {int version}) {
    final newSchema = _createNewSchema(library, fieldses, version: version);

    return migrationGenerator.generate(
      library,
      null,
      newSchema: newSchema,
      version: version,
    );
  }

  /// Create a schema from the contents of all annotated models.
  /// The schema version is incremented from the largest version of all annotated migrations.
  Schema _createNewSchema(LibraryReader library, List<SqliteFields> fieldses, {int version}) {
    final tables = fieldses.fold<Set<SchemaTable>>(<SchemaTable>{}, (acc, fields) {
      final iterableAssociations = fields.stableInstanceFields.where((f) {
        final checker = checkerForField(f);
        final annotation = fields.finder.annotationForField(f);
        return checker.isIterable && checker.isArgTypeASibling && !annotation.ignore;
      });

      if (iterableAssociations.isNotEmpty) {
        iterableAssociations.forEach((iterableSibling) {
          acc.add(_createJoinsTable(
            localTableName: fields.element.name,
            foreignTableColumnDefinition: fields.finder.annotationForField(iterableSibling),
            checker: checkerForField(iterableSibling),
          ));
        });
      }

      acc.add(_createTable(fields.element.name, fields));
      return acc;
    });

    final existingMigrations = migrationGenerator.expandAllMigrations(library);
    version ??= MigrationManager.latestMigrationVersion(existingMigrations);

    return Schema(version, tables: tables);
  }

  SchemaTable _createJoinsTable({
    String localTableName,
    Sqlite foreignTableColumnDefinition,
    SharedChecker checker,
  }) {
    final foreignTableName = checker.unFuturedArgType.getDisplayString();

    return SchemaTable(
        InsertForeignKey.joinsTableName(foreignTableColumnDefinition.name,
            localTableName: localTableName),
        columns: {
          SchemaColumn(
            InsertTable.PRIMARY_KEY_COLUMN,
            int,
            autoincrement: true,
            isPrimaryKey: true,
            nullable: false,
          ),
          SchemaColumn(
            InsertForeignKey.joinsTableLocalColumnName(localTableName),
            int,
            isForeignKey: true,
            foreignTableName: localTableName,
            nullable: foreignTableColumnDefinition?.nullable,
            onDeleteCascade: true,
            onDeleteSetDefault: false,
          ),
          SchemaColumn(
            InsertForeignKey.joinsTableForeignColumnName(foreignTableName),
            int,
            isForeignKey: true,
            foreignTableName: foreignTableName,
            nullable: foreignTableColumnDefinition?.nullable,
            onDeleteCascade: true,
            onDeleteSetDefault: false,
          ),
        },
        indices: {
          SchemaIndex(
            columns: [
              InsertForeignKey.joinsTableLocalColumnName(localTableName),
              InsertForeignKey.joinsTableForeignColumnName(foreignTableName),
            ],
            tableName: InsertForeignKey.joinsTableName(foreignTableColumnDefinition.name,
                localTableName: localTableName),
            unique: true,
          )
        });
  }

  SchemaTable _createTable(String tableName, SqliteFields fields) {
    final columns = _createColumns(fields).where((c) => c != null).toList();
    columns.insert(
      0,
      SchemaColumn(
        InsertTable.PRIMARY_KEY_COLUMN,
        int,
        autoincrement: true,
        isPrimaryKey: true,
        nullable: false,
      ),
    );

    final indices = _createIndices(tableName, fields);

    return SchemaTable(tableName, columns: columns.toSet(), indices: indices);
  }

  @visibleForOverriding
  SharedChecker checkerForField(FieldElement field) {
    var checker = checkerForType(field.type);
    if (checker.isFuture) {
      checker = checkerForType(checker.argType);
    }
    return checker;
  }

  Iterable<SchemaColumn> _createColumns(SqliteFields fields) {
    return fields.stableInstanceFields.map((field) {
      final checker = checkerForField(field);
      final column = fields.finder.annotationForField(field);

      if (column.ignore ||
          column.columnType == null ||
          !checker.isSerializable ||
          (checker.isIterable && checker.isArgTypeASibling)) return null;

      return schemaColumn(column, checker: checker);
    });
  }

  Set<SchemaIndex> _createIndices(String tableName, SqliteFields fields) {
    return fields.stableInstanceFields.fold<Set<SchemaIndex>>({}, (acc, field) {
      final checker = checkerForField(field);
      final column = fields.finder.annotationForField(field);
      final index = schemaIndex(column, checker: checker);
      if (index != null) {
        index.tableName = tableName;
        acc.add(index);
      }
      return acc;
    });
  }

  @visibleForOverriding
  SharedChecker<SqliteModel> checkerForType(DartType type) => SharedChecker<SqliteModel>(type);

  @visibleForOverriding
  @mustCallSuper
  SchemaColumn schemaColumn(Sqlite column, {SharedChecker checker}) {
    if (column.columnType != null) {
      return SchemaColumn(
        column.name,
        null,
        columnType: column.columnType,
        nullable: column?.nullable,
        unique: column?.unique,
      );
    }

    if (checker.isDartCoreType) {
      return SchemaColumn(
        column.name,
        checker.asPrimitive,
        nullable: column?.nullable,
        unique: column?.unique,
      );
    } else if (checker.isEnum) {
      return SchemaColumn(
        column.name,
        int,
        nullable: column?.nullable,
        unique: column?.unique,
      );
    } else if (checker.isSibling) {
      return SchemaColumn(
        InsertForeignKey.foreignKeyColumnName(
            checker.unFuturedType.getDisplayString(), column.name),
        int,
        isForeignKey: true,
        foreignTableName: checker.unFuturedType.getDisplayString(),
        nullable: column?.nullable,
        onDeleteCascade: column?.onDeleteCascade,
        onDeleteSetDefault: column?.onDeleteSetDefault,
      );
    } else if (checker.isMap || checker.isIterable) {
      // Iterables and Maps are stored as JSON
      return SchemaColumn(
        column.name,
        String,
        nullable: column?.nullable,
        unique: column?.unique,
      );
    }

    return null;
  }

  @visibleForOverriding
  SchemaIndex schemaIndex(Sqlite column, {SharedChecker checker}) {
    final isIterableAssociation = (checker.isIterable && checker.isArgTypeASibling);

    if (!column.ignore && column.index && !isIterableAssociation) {
      final name = checker.isSibling
          ? InsertForeignKey.foreignKeyColumnName(
              checker.unFuturedType.getDisplayString(), column.name)
          : column.name;
      return SchemaIndex(
        columns: [name],
        unique: column.unique,
      );
    }

    return null;
  }
}
