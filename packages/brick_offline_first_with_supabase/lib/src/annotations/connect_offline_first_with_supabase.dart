import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';

/// An annotation used to specify a class to generate code for.
///
/// Clones the annotated class to two files for processing by their respective builders
class ConnectOfflineFirstWithSupabase {
  /// Creates a new [ConnectOfflineFirstWithSupabase] instance.
  const ConnectOfflineFirstWithSupabase({
    this.sqliteConfig,
    this.supabaseConfig,
  });

  /// Configuration for the [SqliteSerializable] annotation
  final SqliteSerializable? sqliteConfig;

  /// Configuration for the [SupabaseSerializable] annotation
  final SupabaseSerializable? supabaseConfig;

  /// An instance of [ConnectOfflineFirstWithSupabase] with all fields set to their default
  /// values.
  static const defaults = ConnectOfflineFirstWithSupabase(
    sqliteConfig: SqliteSerializable.defaults,
    supabaseConfig: SupabaseSerializable.defaults,
  );

  /// Returns a new [ConnectOfflineFirstWithSupabase] instance with fields equal to the
  /// corresponding values in `this`, if not `null`.
  ///
  /// Otherwise, the returned value has the default value as defined in
  /// [defaults].
  ConnectOfflineFirstWithSupabase withDefaults() => ConnectOfflineFirstWithSupabase(
        sqliteConfig: sqliteConfig ?? defaults.sqliteConfig,
        supabaseConfig: supabaseConfig ?? defaults.supabaseConfig,
      );
}
