import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart';
import 'package:brick_sqlite_generators/src/sqlite_fields.dart';
import 'package:brick_sqlite_generators/src/sqlite_schema/migration_generator.dart';
import 'package:dart_style/dart_style.dart' as dart_style;
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart' show LibraryReader;
import 'package:source_gen/source_gen.dart';

final _formatter =
    dart_style.DartFormatter(languageVersion: dart_style.DartFormatter.latestLanguageVersion);

///
const migrationGenerator = MigrationGenerator();

/// Produces a [Schema] from all SQLite-enabled annotations
class SqliteSchemaGenerator {
  /// Produces a [Schema] from all SQLite-enabled annotations
  const SqliteSchemaGenerator();

  /// Complete schema file output
  ///
  /// [fieldses] are all classes by their table name
  String generate(LibraryReader library, List<SqliteFields> fieldses) {
    final newSchema = _createNewSchema(library, fieldses);
    final existingMigrations = migrationGenerator.expandAllMigrations(library);

    final parts = existingMigrations.map((m) => "part '${m.version}.migration.dart';");
    final migrationClasses = existingMigrations.map((m) => 'const Migration${m.version}()');

    final output = """
      // GENERATED CODE DO NOT EDIT
      // This file should be version controlled
      import 'package:brick_sqlite/db.dart';
      ${parts.join("\n")}

      /// All intelligently-generated migrations from all `@Migratable` classes on disk
      final migrations = <Migration>{ ${migrationClasses.join(",\n")} };

      /// A consumable database structure including the latest generated migration.
      final schema = ${newSchema.forGenerator};
    """;
    return _formatter.format(output);
  }

  /// Produce a migration from the difference between existing migrations and the latest schema
  String? createMigration(LibraryReader library, List<SqliteFields> fieldses, {int? version}) {
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
  Schema _createNewSchema(LibraryReader library, List<SqliteFields> fieldses, {int? version}) {
    final tables = fieldses.fold<Set<SchemaTable>>(<SchemaTable>{}, (acc, fields) {
      final iterableAssociations = fields.stableInstanceFields.where((f) {
        final checker = checkerForField(f);
        final annotation = fields.finder.annotationForField(f);
        return checker.isIterable && checker.isArgTypeASibling && !annotation.ignore;
      });

      if (iterableAssociations.isNotEmpty) {
        for (final iterableSibling in iterableAssociations) {
          acc.add(
            _createJoinsTable(
              localTableName: fields.element.name,
              foreignTableColumnDefinition: fields.finder.annotationForField(iterableSibling),
              checker: checkerForField(iterableSibling),
            ),
          );
        }
      }

      acc.add(_createTable(fields.element.name, fields));
      return acc;
    });

    final existingMigrations = migrationGenerator.expandAllMigrations(library);
    version ??= MigrationManager.latestMigrationVersion(existingMigrations);

    return Schema(version, tables: tables);
  }

  SchemaTable _createJoinsTable({
    required String localTableName,
    required Sqlite foreignTableColumnDefinition,
    required SharedChecker checker,
  }) {
    final foreignTableName = SharedChecker.withoutNullability(checker.unFuturedArgType);

    return SchemaTable(
      InsertForeignKey.joinsTableName(
        foreignTableColumnDefinition.name!,
        localTableName: localTableName,
      ),
      columns: {
        SchemaColumn(
          InsertTable.PRIMARY_KEY_COLUMN,
          Column.integer,
          autoincrement: true,
          isPrimaryKey: true,
          nullable: false,
        ),
        SchemaColumn(
          InsertForeignKey.joinsTableLocalColumnName(localTableName),
          Column.integer,
          isForeignKey: true,
          foreignTableName: localTableName,
          nullable: foreignTableColumnDefinition.nullable,
          onDeleteCascade: true,
        ),
        SchemaColumn(
          InsertForeignKey.joinsTableForeignColumnName(foreignTableName),
          Column.integer,
          isForeignKey: true,
          foreignTableName: foreignTableName,
          nullable: foreignTableColumnDefinition.nullable,
          onDeleteCascade: true,
        ),
      },
      indices: {
        SchemaIndex(
          columns: [
            InsertForeignKey.joinsTableLocalColumnName(localTableName),
            InsertForeignKey.joinsTableForeignColumnName(foreignTableName),
          ],
          tableName: InsertForeignKey.joinsTableName(
            foreignTableColumnDefinition.name!,
            localTableName: localTableName,
          ),
          unique: true,
        ),
      },
    );
  }

  SchemaTable _createTable(String tableName, SqliteFields fields) {
    final columns = _createColumns(fields).where((c) => c != null).toList()
      ..insert(
        0,
        SchemaColumn(
          InsertTable.PRIMARY_KEY_COLUMN,
          Column.integer,
          autoincrement: true,
          isPrimaryKey: true,
          nullable: false,
        ),
      );

    final indices = _createIndices(tableName, fields);

    return SchemaTable(
      tableName,
      columns: columns.whereType<SchemaColumn>().toSet(),
      indices: indices,
    );
  }

  ///
  @visibleForOverriding
  SharedChecker checkerForField(FieldElement field) {
    var checker = checkerForType(field.type);
    if (checker.isFuture) {
      checker = checkerForType(checker.argType);
    }
    return checker;
  }

  Iterable<SchemaColumn?> _createColumns(SqliteFields fields) {
    return fields.stableInstanceFields.map((field) {
      final checker = checkerForField(field);
      final column = fields.finder.annotationForField(field);

      if (column.ignore) return null;

      // ignore all other checks if a custom column type is defined
      if (column.columnType != null) {
        return schemaColumn(column, checker: checker);
      }

      if (checker.isSerializableViaJson(false)) return schemaColumn(column, checker: checker);

      if (!checker.isSerializable || (checker.isIterable && checker.isArgTypeASibling)) return null;

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

  ///
  @visibleForOverriding
  SharedChecker<SqliteModel> checkerForType(DartType type) => SharedChecker<SqliteModel>(type);

  ///
  @mustCallSuper
  SchemaColumn? schemaColumn(Sqlite column, {required SharedChecker checker}) {
    if (column.columnType != null) {
      return SchemaColumn(
        column.name!,
        column.columnType!,
        nullable: column.nullable,
        unique: column.unique,
      );
    }

    if (checker.isDartCoreType) {
      return SchemaColumn(
        column.name!,
        Column.fromDartPrimitive(checker.asPrimitive),
        nullable: column.nullable,
        unique: column.unique,
      );
    } else if (checker.isEnum) {
      return SchemaColumn(
        column.name!,
        column.enumAsString ? Column.varchar : Column.integer,
        nullable: column.nullable,
        unique: column.unique,
      );
    } else if (checker.isSibling) {
      return SchemaColumn(
        InsertForeignKey.foreignKeyColumnName(
          SharedChecker.withoutNullability(checker.unFuturedType),
          column.name,
        ),
        Column.integer,
        isForeignKey: true,
        foreignTableName: SharedChecker.withoutNullability(checker.unFuturedType),
        nullable: column.nullable,
        onDeleteCascade: column.onDeleteCascade,
        onDeleteSetDefault: column.onDeleteSetDefault,
      );
    } else if (checker.isMap || checker.isIterable) {
      // Iterables and Maps are stored as JSON
      return SchemaColumn(
        column.name!,
        Column.varchar,
        nullable: column.nullable,
        unique: column.unique,
      );
    } else if (checker.toJsonMethod != null) {
      return SchemaColumn(
        column.name!,
        Column.varchar,
        nullable: column.nullable,
        unique: column.unique,
      );
    }

    return null;
  }

  ///
  @visibleForOverriding
  SchemaIndex? schemaIndex(Sqlite column, {required SharedChecker checker}) {
    final isIterableAssociation = checker.isIterable && checker.isArgTypeASibling;

    if (!column.ignore && column.index && !isIterableAssociation) {
      final name = checker.isSibling
          ? InsertForeignKey.foreignKeyColumnName(
              SharedChecker.withoutNullability(checker.unFuturedType),
              column.name,
            )
          : column.name!;
      return SchemaIndex(
        columns: [name],
        unique: column.unique,
      );
    }

    return null;
  }
}
