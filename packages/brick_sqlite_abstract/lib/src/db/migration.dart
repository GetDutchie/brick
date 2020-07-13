// Heavily, heavily inspired by [Aqueduct](https://github.com/stablekernel/aqueduct/blob/master/aqueduct/lib/src/db/schema/migration.dart)

import 'package:meta/meta.dart';
import 'migration_commands/migration_command.dart';

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
  Double,
  integer,
  float,
  num,
  text,
  varchar
}

abstract class Migration {
  /// Order to run; should be unique and sequential with other [Migration]s
  final int version;

  final List<MigrationCommand> up;
  final List<MigrationCommand> down;

  const Migration({@required this.version, @required this.up, @required this.down});

  String get statement => upStatement;

  String get upStatement => up.map((c) => c.statement).join(';\n') + ';';

  String get downStatement => down.map((c) => c.statement).join(';\n') + ';';

  /// Convert `Column` to SQLite data types
  static String ofDefinition(Column definition) {
    switch (definition) {
      case Column.bigint:
        return 'BIGINT';
        break;
      case Column.boolean:
        return 'BOOLEAN';
        break;
      case Column.blob:
        return 'BLOB';
        break;
      case Column.date:
        return 'DATE';
        break;
      case Column.datetime:
        return 'DATETIME';
        break;
      case Column.Double:
      case Column.num:
        return 'DOUBLE';
        break;
      case Column.integer:
        return 'INTEGER';
        break;
      case Column.float:
        return 'FLOAT';
        break;
      case Column.text:
        return 'TEXT';
        break;
      case Column.varchar:
        return 'VARCHAR';
        break;
      default:
        return throw ArgumentError('$definition not found in Column');
    }
  }

  /// Convert native Dart to `Column`
  static Column fromDartPrimitive(Type type) {
    switch (type) {
      case bool:
        return Column.boolean;
        break;
      case DateTime:
        return Column.datetime;
        break;
      case double:
        return Column.Double;
        break;
      case int:
        return Column.integer;
        break;
      case num:
        return Column.num;
        break;
      case String:
        return Column.varchar;
        break;
      default:
        return throw ArgumentError('$type not associated with a Column');
    }
  }

  /// Convert `Column` to native Dart
  static Type toDartPrimitive(Column definition) {
    switch (definition) {
      case Column.bigint:
        return num;
        break;
      case Column.boolean:
        return bool;
        break;
      case Column.blob:
        return List;
        break;
      case Column.date:
        return DateTime;
        break;
      case Column.datetime:
        return DateTime;
        break;
      case Column.Double:
        return double;
        break;
      case Column.integer:
        return int;
        break;
      case Column.float:
      case Column.num:
        return num;
        break;
      case Column.text:
        return String;
        break;
      case Column.varchar:
        return String;
        break;
      default:
        return throw ArgumentError('$definition not found in Column');
    }
  }

  static String generate(List<MigrationCommand> commands, int version) {
    final upCommands = commands.map((m) => m.forGenerator).join(',\n  ');
    final downCommands = commands.map((m) => m.down?.forGenerator).toList();
    downCommands.removeWhere((m) => m == null);

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
  $upCommands
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
      identical(this, other) || other is Migration && version == other?.version;

  @override
  int get hashCode => version.hashCode;
}
