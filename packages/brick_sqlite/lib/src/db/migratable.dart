import 'package:brick_sqlite/src/db/migration.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';

/// Annotation required by the generator for AOT discoverability. Decorates classes
/// that `extends Migration`.
class Migratable {
  /// The [Migration] down commands. Must match the annotated [Migration] up.
  final List<MigrationCommand> down;

  /// The [Migration] up commands. Must match the annotated [Migration] up.
  final List<MigrationCommand> up;

  /// The [Migration] version. Must match the annotated [Migration] version.
  /// While [int] is a more appropriate type, [String] is used instead to help the
  /// generator parse longer integers (such as a timestamp with seconds) when decoding
  /// from a constant reader.
  ///
  /// However, as other classes such as the Migration Manager sort on this property,
  /// the version should still match `RegExp("^\d+$")`.
  final String version;

  /// Annotation required by the generator for AOT discoverability. Decorates classes
  /// that `extends Migration`.
  const Migratable({
    required this.down,
    required this.up,
    required this.version,
  });
}
