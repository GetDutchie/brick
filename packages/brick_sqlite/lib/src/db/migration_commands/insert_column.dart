import 'package:brick_sqlite/src/db/column.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';

/// Creates a new SQLite column in a table
class InsertColumn extends MigrationCommand {
  ///
  final String name;

  /// Column type
  final Column definitionType;

  ///
  final String onTable;

  /// Column can be `NULL`. Defaults `true`.
  final bool nullable;

  /// `DEFAULT` value when insertion is null. Must be a Dart primitive.
  final dynamic defaultValue;

  /// Column has `AUTOINCREMENT`. Must be type of `int`. Defaults `false`.
  final bool autoincrement;

  /// Column has `UNIQUE` constraint. Defaults `false`.
  final bool unique;

  /// Creates a new SQLite column in a table
  const InsertColumn(
    this.name,
    this.definitionType, {
    required this.onTable,
    this.defaultValue,
    this.autoincrement = false,
    this.nullable = true,
    this.unique = false,
  });

  String? get _defaultStatement {
    if (defaultValue == null) {
      return null;
    }

    return 'DEFAULT $defaultValue';
  }

  String get _nullStatement => nullable ? 'NULL' : 'NOT NULL';

  String? get _autoincrementStatement {
    if (!autoincrement) return null;

    return 'AUTOINCREMENT';
  }

  ///
  String get definition => definitionType.definition;

  String get _addons {
    final list = [_autoincrementStatement, _nullStatement, _defaultStatement]
      ..removeWhere((s) => s == null);
    return list.join(' ');
  }

  @override
  String get statement => 'ALTER TABLE `$onTable` ADD `$name` $definition $_addons';

  @override
  String get forGenerator {
    final parts = [
      "'$name'",
      definitionType,
      "onTable: '$onTable'",
    ];

    if (defaultValue != null) {
      parts.add('defaultValue: $defaultValue');
    }

    if (autoincrement != defaults.autoincrement) {
      parts.add('autoincrement: $autoincrement');
    }

    if (nullable != defaults.nullable) {
      parts.add('nullable: $nullable');
    }

    if (unique != defaults.unique) {
      parts.add('unique: $unique');
    }

    return 'InsertColumn(${parts.join(', ')})';
  }

  @override
  MigrationCommand get down => DropColumn(name, onTable: onTable);

  /// Defaults
  static const defaults = InsertColumn(
    'PLACEHOLDER',
    Column.varchar,
    onTable: 'PLACEHOLDER',
  );
}
