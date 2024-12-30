/// Used to define types in [SqliteAdapter#fieldsToSqliteColumns]. The build runner package
/// extracts types and associations that would've been otherwise inaccessible at runtime.
class RuntimeSqliteColumnDefinition {
  /// Whether this column relates to another SqliteModel
  /// This is true for `Iterable<SqliteModel>` and `SqliteModel`. Defaults to `false`.
  final bool association;

  /// The SQLite column name, **not** the field name.
  final String columnName;

  /// Whether this column is any subset `Iterable` (e.g. `List`, `Set`).
  /// Defaults to `false`.
  final bool iterable;

  /// The type accessed after the result is retrieved, **not** the SQLite column type.
  /// In other words, the runtime type.
  final Type type;

  /// Used to define types in [SqliteAdapter#fieldsToSqliteColumns]. The build runner package
  /// extracts types and associations that would've been otherwise inaccessible at runtime.
  const RuntimeSqliteColumnDefinition({
    this.association = false,
    required this.columnName,
    this.iterable = false,
    required this.type,
  });
}
