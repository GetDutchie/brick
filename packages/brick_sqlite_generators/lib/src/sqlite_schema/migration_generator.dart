import 'package:analyzer/dart/constant/value.dart';
import 'package:brick_sqlite/db.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

const _migrationAnnotationChecker = TypeChecker.fromRuntime(Migratable);
const _createIndexChecker = TypeChecker.fromRuntime(CreateIndex);
const _dropIndexChecker = TypeChecker.fromRuntime(DropIndex);
const _dropColumnChecker = TypeChecker.fromRuntime(DropColumn);
const _dropTableChecker = TypeChecker.fromRuntime(DropTable);
const _insertColumnChecker = TypeChecker.fromRuntime(InsertColumn);
const _insertForeignKeyChecker = TypeChecker.fromRuntime(InsertForeignKey);
const _insertTableChecker = TypeChecker.fromRuntime(InsertTable);
const _renameColumnChecker = TypeChecker.fromRuntime(RenameColumn);
const _renameTableChecker = TypeChecker.fromRuntime(RenameTable);

/// [Migration] is an abstract class; this is a library-specific implementation
/// to access migration properties.
class _MigrationImpl extends Migration {
  const _MigrationImpl({
    required super.version,
    required super.up,
    required super.down,
  });
}

/// Recreate existing migrations as manageable objects.
/// Eventually used in [SchemaDifference] to generate new [Migration]s
class MigrationGenerator extends Generator {
  ///
  static final emptySchema = Schema(0, tables: <SchemaTable>{});

  /// Recreate existing migrations as manageable objects.
  /// Eventually used in [SchemaDifference] to generate new [Migration]s
  const MigrationGenerator();

  /// Search [library] for all classes that extend [Migration]. Recreate these in Dart Code
  Iterable<Migration> expandAllMigrations(LibraryReader library) {
    final classes = library.annotatedWith(_migrationAnnotationChecker);

    return classes.map((migration) {
      final reader = migration.annotation;
      return _MigrationImpl(
        version: int.parse(reader.read('version').stringValue),
        up: _migrationCommandsFromReader(reader.read('up').listValue),
        down: _migrationCommandsFromReader(reader.read('down').listValue),
      );
    });
  }

  /// Convert [MigrationCommand]s in constant form to [MigrationCommand]s
  List<MigrationCommand> _migrationCommandsFromReader(List<DartObject> rawCommands) {
    return rawCommands.map((object) {
      final reader = ConstantReader(object);
      if (_createIndexChecker.isExactlyType(object.type!)) {
        if (!reader.read('columns').isList) {
          throw ArgumentError(
            'CreateIndex on ${reader.read('onTable').stringValue} has malformed columns',
          );
        }
        final columns = reader.read('columns').listValue.map((o) => o.toStringValue());

        return CreateIndex(
          columns: columns.toList().cast<String>(),
          onTable: reader.read('onTable').stringValue,
          unique: reader.read('unique').boolValue,
        );
      } else if (_dropColumnChecker.isExactlyType(object.type!)) {
        return DropColumn(
          reader.read('name').stringValue,
          onTable: reader.read('onTable').stringValue,
        );
      } else if (_dropIndexChecker.isExactlyType(object.type!)) {
        return DropIndex(reader.read('name').stringValue);
      } else if (_dropTableChecker.isExactlyType(object.type!)) {
        return DropTable(
          reader.read('name').stringValue,
        );
      } else if (_insertColumnChecker.isExactlyType(object.type!)) {
        final definitionObject = reader.read('definitionType').objectValue;
        final columnIndex = definitionObject.getField('index')!.toIntValue()!;
        final definitionValue = Column.values[columnIndex];
        return InsertColumn(
          reader.read('name').stringValue,
          definitionValue,
          autoincrement: reader.read('autoincrement').isNull
              ? InsertColumn.defaults.autoincrement
              : reader.read('autoincrement').boolValue,
          defaultValue: reader.read('defaultValue').isNull
              ? InsertColumn.defaults.defaultValue
              : reader.read('defaultValue').literalValue,
          nullable: reader.read('nullable').isNull
              ? InsertColumn.defaults.nullable
              : reader.read('nullable').boolValue,
          onTable: reader.read('onTable').stringValue,
          unique: reader.read('unique').isNull
              ? InsertColumn.defaults.unique
              : reader.read('unique').boolValue,
        );
      } else if (_insertForeignKeyChecker.isExactlyType(object.type!)) {
        return InsertForeignKey(
          reader.read('localTableName').stringValue,
          reader.read('foreignTableName').stringValue,
          foreignKeyColumn: reader.read('foreignKeyColumn').isNull
              ? null
              : reader.read('foreignKeyColumn').stringValue,
          onDeleteCascade:
              !reader.read('onDeleteCascade').isNull && reader.read('onDeleteCascade').boolValue,
          onDeleteSetDefault: !reader.read('onDeleteSetDefault').isNull &&
              reader.read('onDeleteSetDefault').boolValue,
        );
      } else if (_insertTableChecker.isExactlyType(object.type!)) {
        return InsertTable(
          reader.read('name').stringValue,
        );
      } else if (_renameColumnChecker.isExactlyType(object.type!)) {
        return RenameColumn(
          reader.read('oldName').stringValue,
          reader.read('newName').stringValue,
          onTable: reader.read('onTable').stringValue,
        );
      } else if (_renameTableChecker.isExactlyType(object.type!)) {
        return RenameTable(
          reader.read('oldName').stringValue,
          reader.read('newName').stringValue,
        );
      } else {
        throw UnimplementedError('Cannot create migration line for ${object.type}');
      }
    }).toList();
  }

  /// Creates a new migration from the delta between the existing migration and a new schema
  @override
  String? generate(LibraryReader library, BuildStep? buildStep, {Schema? newSchema, int? version}) {
    final allMigrations = expandAllMigrations(library);
    final oldSchema = Schema.fromMigrations(allMigrations.toSet());

    final difference = newSchema == null
        ? SchemaDifference(emptySchema, oldSchema)
        : SchemaDifference(oldSchema, newSchema);

    if (!difference.hasDifference || difference.toMigrationCommands().isEmpty) {
      return null;
    }

    final output = Migration.generate(difference.toMigrationCommands(), version!);

    return output;
  }

  /// Find all annotated migrations and bundle them with their source path.
  /// Useful for generating an import or list of all migrations.
  static Map<String, String> allMigrationsByFilePath(LibraryReader library) {
    final annotations = library.annotatedWith(_migrationAnnotationChecker);
    return {
      for (final annotation in annotations)
        '${annotation.element.name}': annotation.element.source!.shortName,
    };
  }
}
