/// Used to define types in [SupabaseAdapter#supabaseFieldsToColumns]. The build runner package
/// extracts types and associations that would've been otherwise inaccessible at runtime.
class RuntimeSupabaseColumnDefinition {
  /// Whether this column relates to another table in Supabase
  /// This is true for `Iterable<SupabaseModel>` and `SupabaseModel`. Defaults to `false`.
  final bool association;

  /// The column in the class's table that relates to another table in Supabase.
  /// For example, given the Supabase table `users` with a column of `address_id` indexing
  /// to the table `addresses`, `'address_id'` would be this value.
  final String? associationForeignKey;

  /// The Dart type if [association] is `true`. This value has no nullability suffixes
  /// and is not wrapped in `Future` or any other `Iterable` type.
  final Type? associationType;

  /// The Supabase column name, **not** the field name unless this definition is an association.
  /// Then the [columnName] should reflect the Dart field name for deserialization.
  final String columnName;

  const RuntimeSupabaseColumnDefinition({
    this.association = false,
    this.associationForeignKey,
    this.associationType,
    required this.columnName,
  });
}
