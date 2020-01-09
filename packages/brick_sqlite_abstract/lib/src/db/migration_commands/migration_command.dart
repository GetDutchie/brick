/// Extendible interface for SQLite migrations
abstract class MigrationCommand {
  /// Outputs statement to be interpreted by SQLite
  String get statement;

  /// Outputs model as String to be used in a generator
  String get forGenerator;

  /// Outputs the opposite command to be used in a generator
  MigrationCommand get down => null;

  /// Alias for [statement]
  toString() => statement;

  const MigrationCommand();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MigrationCommand &&
          this?.statement == other?.statement &&
          this?.forGenerator == other?.forGenerator;

  @override
  int get hashCode => statement.hashCode ^ forGenerator.hashCode;
}
