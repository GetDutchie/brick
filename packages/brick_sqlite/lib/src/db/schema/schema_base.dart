import 'package:brick_sqlite/src/db/migration.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';

/// Generates code for [Migration] from [BaseSchemaObject]ss
abstract class BaseSchemaObject {
  /// Generated Dart code to include in a migrations file.
  MigrationCommand toCommand();

  /// Generated Dart code to include in a schema.
  String get forGenerator;
}
