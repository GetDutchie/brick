import 'package:meta/meta.dart';
import 'migration.dart';

/// Holds all migrations and outputs statements for SQLite to consume
class MigrationManager {
  @protected
  final Set<Migration> migrations;

  const MigrationManager(this.migrations);

  /// Identifies the latest migrations, especially those not yet added to the [Schema]
  /// The delta between [Schema]'s version and [MigrationManager]'s are unprocessed migrations
  int get version {
    return latestMigrationVersion(migrations);
  }

  /// Key/value migrations based on their version
  Map<int, Migration> get migrationByVersion {
    return {for (var m in migrations) m.version: m};
  }

  /// Migrations after a version
  ///
  /// [versionNumber] defaults to [version]
  List<Migration> migrationsSince([int? versionNumber]) {
    final number = versionNumber ?? version;
    final validMigrations = migrations.where((m) => m.version > number).toList();
    validMigrations.sort((a, b) => a.version.compareTo(b.version));
    return validMigrations;
  }

  /// Migrations before and including a version
  ///
  /// [versionNumber] defaults to [version]
  Map<int, Migration> migrationsUntil([int? versionNumber]) {
    return migrationByVersion
      ..removeWhere((version, _) {
        return version > (versionNumber ?? version);
      });
  }

  /// Migration at a version
  Migration? migrationAt(int versionNumber) {
    return migrationByVersion[versionNumber];
  }

  /// Sort migrations by their version number in ascending order
  /// and return the latest [Migration] version or `0` if [allMigrations] is empty
  static int latestMigrationVersion(Iterable<Migration> allMigrations) {
    if (allMigrations.isEmpty) {
      return 0;
    }

    final versions = allMigrations.map((m) => m.version).toList();
    versions.sort();
    return versions.last;
  }
}
