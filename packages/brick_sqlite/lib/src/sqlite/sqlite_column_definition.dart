/// Used to define types in [sqliteFieldsToColumns]. THe build runner package
/// extracts types and associations that are inaccessible at runtime.
class SqliteColumnDefinition {
  /// Whether this column relates to another SqliteModel
  /// This is true for `List<SqliteModel>`, `SqliteModel`. Defaults to `false`.
  final bool association;

  /// The SQLite column name, **not** the field name.
  final String columnName;

  /// Whether this column is any subset `Iterable` (e.g. `List`, `Set`)
  final bool iterable;

  /// The type accessed after the result is retrieved, **not** the SQLite column type.
  /// In other words, the runtime type.
  final Type type;

  SqliteColumnDefinition({
    this.association = false,
    this.columnName,
    this.iterable = false,
    this.type,
  });
}
