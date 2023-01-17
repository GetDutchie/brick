// Heavily, heavily inspired by [Aqueduct](https://github.com/stablekernel/aqueduct/blob/master/aqueduct/lib/src/db/schema/migration.dart)

import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';

/// SQLite data types.
///
/// While SQLite only supports 5 datatypes, it will still cast these
/// into an [intelligent affinity](https://www.sqlite.org/datatype3.html).
enum Column {
  undefined,
  bigint,
  blob,
  boolean,
  date,
  datetime,
  // ignore: constant_identifier_names
  Double,
  integer,
  float,

  /// DOUBLE column type is used
  num,
  text,
  varchar
}

abstract class Migration {
  /// Order to run; should be unique and sequential with other [Migration]s
  final int version;

  final List<MigrationCommand> up;
  final List<MigrationCommand> down;

  const Migration({
    required this.version,
    required this.up,
    required this.down,
  });

  String get statement => upStatement;

  String get upStatement => up.map((c) => c.statement).join(';\n') + ';';

  String get downStatement => down.map((c) => c.statement).join(';\n') + ';';

  /// Convert `Column` to SQLite data types
  static String ofDefinition(Column definition) {
    switch (definition) {
      case Column.bigint:
        return 'BIGINT';
      case Column.boolean:
        return 'BOOLEAN';
      case Column.blob:
        return 'BLOB';
      case Column.date:
        return 'DATE';
      case Column.datetime:
        return 'DATETIME';
      case Column.Double:
      case Column.num:
        return 'DOUBLE';
      case Column.integer:
        return 'INTEGER';
      case Column.float:
        return 'FLOAT';
      case Column.text:
        return 'TEXT';
      case Column.varchar:
        return 'VARCHAR';
      default:
        return throw ArgumentError('$definition not found in Column');
    }
  }

  /// Convert native Dart to `Column`
  static Column fromDartPrimitive(Type type) {
    switch (type) {
      case bool:
        return Column.boolean;
      case DateTime:
        return Column.datetime;
      case double:
        return Column.Double;
      case int:
        return Column.integer;
      case num:
        return Column.num;
      case String:
        return Column.varchar;
      default:
        return throw ArgumentError('$type not associated with a Column');
    }
  }

  /// Convert `Column` to native Dart
  static Type toDartPrimitive(Column definition) {
    switch (definition) {
      case Column.bigint:
        return num;
      case Column.boolean:
        return bool;
      case Column.blob:
        return List;
      case Column.date:
        return DateTime;
      case Column.datetime:
        return DateTime;
      case Column.Double:
        return double;
      case Column.integer:
        return int;
      case Column.float:
      case Column.num:
        return num;
      case Column.text:
        return String;
      case Column.varchar:
        return String;
      default:
        return throw ArgumentError('$definition not found in Column');
    }
  }

  static String generate(List<MigrationCommand> commands, int version) {
    final upCommands = commands.map((m) => m.forGenerator);
    final downCommands = commands.map((m) => m.down?.forGenerator).toList().whereType<String>();

    return '''
// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_${version}_up = [
  ${upCommands.join(',\n  ')}
];

const List<MigrationCommand> _migration_${version}_down = [
  ${downCommands.join(',\n  ')}
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '$version',
  up: _migration_${version}_up,
  down: _migration_${version}_down,
)
class Migration$version extends Migration {
  const Migration$version()
    : super(
        version: $version,
        up: _migration_${version}_up,
        down: _migration_${version}_down,
      );
}
''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Migration && version == other.version;

  @override
  int get hashCode => version.hashCode;
}
