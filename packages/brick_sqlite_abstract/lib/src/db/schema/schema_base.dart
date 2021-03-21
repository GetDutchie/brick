import 'package:brick_sqlite_abstract/src/db/migration_commands.dart';

/// Generates code for [Migration] from [BaseSchemaObject]ss
abstract class BaseSchemaObject {
  /// Generated Dart code to include in a migrations file.
  MigrationCommand toCommand();

  /// Generated Dart code to include in a schema.
  String get forGenerator;
}
