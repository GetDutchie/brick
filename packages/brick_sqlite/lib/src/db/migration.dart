// Heavily, heavily inspired by [Aqueduct](https://github.com/stablekernel/aqueduct/blob/master/aqueduct/lib/src/db/schema/migration.dart)
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';
import 'package:brick_sqlite/src/db/schema/schema.dart';

/// A collection of [MigrationCommand]s to update the [Schema].
abstract class Migration {
  /// Order to run; should be unique and sequential with other [Migration]s
  final int version;

  /// Desired changes to the [Schema].
  final List<MigrationCommand> up;

  /// Reverts [up]
  final List<MigrationCommand> down;

  /// A collection of [MigrationCommand]s to update the [Schema].
  const Migration({
    required this.version,
    required this.up,
    required this.down,
  });

  /// Alias of [upStatement]
  String get statement => upStatement;

  /// Generate SQL statements for all commands
  String get upStatement => '${up.map((c) => c.statement).join(';\n')};';

  /// Revert of [upStatement]
  String get downStatement => '${down.map((c) => c.statement).join(';\n')};';

  /// SQL command to produce the migration
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
