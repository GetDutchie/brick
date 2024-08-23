/// Used to define types in [SupabaseAdapter#supabaseFieldsToColumns]. The build runner package
/// extracts types and associations that would've been otherwise inaccessible at runtime.
class RuntimeSupabaseColumnDefinition {
  /// Whether this column relates to another table in Supabase
  /// This is true for `Iterable<SupabaseModel>` and `SupabaseModel`. Defaults to `false`.
  final bool association;

  final String? associationForeignKey;

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
