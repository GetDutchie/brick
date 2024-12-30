import 'package:brick_sqlite/src/db/migration.dart';
import 'package:brick_sqlite/src/db/schema/schema.dart';
import 'package:meta/meta.dart';

/// Holds all migrations and outputs statements for SQLite to consume
class MigrationManager {
  ///
  @protected
  final Set<Migration> migrations;

  /// Holds all migrations and outputs statements for SQLite to consume
  const MigrationManager(this.migrations);

  /// Identifies the latest migrations, especially those not yet added to the [Schema]
  /// The delta between [Schema]'s version and [MigrationManager]'s are unprocessed migrations
  int get version => latestMigrationVersion(migrations);

  /// Key/value migrations based on their version
  Map<int, Migration> get migrationByVersion => {for (final m in migrations) m.version: m};

  /// Migrations after a version
  ///
  /// [versionNumber] defaults to [version]
  List<Migration> migrationsSince([int? versionNumber]) {
    final number = versionNumber ?? version;
    return migrations.where((m) => m.version > number).toList()
      ..sort((a, b) => a.version.compareTo(b.version));
  }

  /// Migrations before and including a version
  ///
  /// [versionNumber] defaults to [version]
  Map<int, Migration> migrationsUntil([int? versionNumber]) =>
      migrationByVersion..removeWhere((version, _) => version > (versionNumber ?? version));

  /// Migration at a version
  Migration? migrationAt(int versionNumber) => migrationByVersion[versionNumber];

  /// Sort migrations by their version number in ascending order
  /// and return the latest [Migration] version or `0` if [allMigrations] is empty
  static int latestMigrationVersion(Iterable<Migration> allMigrations) {
    if (allMigrations.isEmpty) {
      return 0;
    }

    final versions = allMigrations.map((m) => m.version).toList()..sort();
    return versions.last;
  }
}
