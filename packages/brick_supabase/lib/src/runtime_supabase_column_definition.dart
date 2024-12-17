/// Used to define types in [SupabaseAdapter#supabaseFieldsToColumns]. The build runner package
/// extracts types and associations that would've been otherwise inaccessible at runtime.
class RuntimeSupabaseColumnDefinition {
  /// Whether this column relates to another table in Supabase
  /// This is true for `Iterable<SupabaseModel>` and `SupabaseModel`. Defaults to `false`.
  final bool association;

  /// Whether the [associationType] can be `null`.
  final bool associationIsNullable;

  /// The Dart type if [association] is `true`. This value has no nullability suffixes
  /// and is not wrapped in `Future` or any other `Iterable` type.
  final Type? associationType;

  /// The Supabase column name, **not** the field name unless this definition is an association.
  /// Then the [columnName] should reflect the Dart field name for deserialization.
  final String columnName;

  /// When specified, this value will be used in the ON clause of the association query.
  /// For example, `'customer_id'` in `customer:customers!customer_id(...)`.
  ///
  /// When left unspecified, the query will not use a foreign key.
  /// (e.g. `customer:customers(...)`)
  final String? foreignKey;

  /// Forwarded from `@Supabase(query:)`, this overrides the generated query.
  final String? query;

  /// Used to define types in [SupabaseAdapter#supabaseFieldsToColumns]. The build runner package
  /// extracts types and associations that would've been otherwise inaccessible at runtime.
  const RuntimeSupabaseColumnDefinition({
    this.association = false,
    this.associationIsNullable = false,
    this.associationType,
    required this.columnName,
    this.foreignKey,
    this.query,
  });
}
