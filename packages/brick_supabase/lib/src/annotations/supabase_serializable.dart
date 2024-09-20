import 'package:brick_core/field_rename.dart';

/// An annotation used to specify a class to generate Supabase code for.
///
/// Creates a serialize/deserialize function for JSON.
//
// Heavily borrowed/inspired by [JsonSerializable](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_serializable.dart)
class SupabaseSerializable {
  /// Forwards to Supabase's defaultToNull parameter.
  final bool defaultToNull;

  /// Defines the automatic naming strategy when converting class field names
  /// into JSON map keys.
  ///
  /// The value for `@Supabase(name:)` will override this convention.
  ///
  /// Defaults to `FieldRename.snake` case.
  final FieldRename fieldRename;

  /// Forwards to Supabase's `ignoreDuplicates` parameter.
  final bool ignoreDuplicates;

  /// Forwards to Supabase's `onConflict` parameter.
  /// This should be comma-separated Supabase column names, not Dart fields.
  final String? onConflict;

  /// The Supabase table name to fetch from. For example, `"users"`
  /// in `Supabase.instance.client.from("users")`.
  /// The schema name is not required.
  ///
  /// Defaults to snake case of the class name + a trailing s.
  /// It does not handle complex pluralization (e.g. 'Person' -> 'People').
  final String? tableName;

  /// Creates a new [SupabaseSerializable] instance.
  const SupabaseSerializable({
    this.defaultToNull = true,
    this.fieldRename = FieldRename.snake,
    this.ignoreDuplicates = false,
    this.onConflict,
    this.tableName,
  });

  /// An instance of [SupabaseSerializable] with all fields set to their default
  /// values.
  static const defaults = SupabaseSerializable();
}
