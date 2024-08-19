/// An annotation used to specify a class to generate Supabase code for.
///
/// Creates a serialize/deserialize function for JSON.
//
// Heavily borrowed/inspired by [JsonSerializable](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_serializable.dart)
class SupabaseSerializable {
  /// Forwards to Supabase's defaultToNull parameter.
  final bool defaultToNull;

  /// Forwards to Supabase's ignoreDuplicates parameter.
  final bool ignoreDuplicates;

  /// Forwards to Supabase's onConflict parameter.
  final String? onConflict;

  /// The Supabase table name to fetch from. For example, `"users"`
  /// in `Supabase.instance.client.from("users")`.
  /// The schema name is not required.
  final String tableName;

  /// Creates a new [SupabaseSerializable] instance.
  const SupabaseSerializable({
    this.defaultToNull = true,
    this.ignoreDuplicates = false,
    this.onConflict,
    required this.tableName,
  });

  /// An instance of [SupabaseSerializable] with all fields set to their default
  /// values.
  static const defaults = SupabaseSerializable(
    defaultToNull: true,
    ignoreDuplicates: false,
    onConflict: null,
    tableName: '',
  );
}
