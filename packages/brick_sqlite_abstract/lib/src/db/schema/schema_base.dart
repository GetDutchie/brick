import '../migration_commands.dart' show MigrationCommand;

/// Generates code for [Migration] from [BaseSchemaObject]ss
abstract class BaseSchemaObject {
  String name;

  /// Generated Dart code to include in a migrations file.
  MigrationCommand toCommand();

  /// Generated Dart code to include in a schema.
  String get forGenerator;
}
