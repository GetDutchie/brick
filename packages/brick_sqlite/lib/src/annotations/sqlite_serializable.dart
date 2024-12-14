import 'package:brick_sqlite/src/annotations/sqlite.dart';

/// An annotation used to specify a class to generate code for.
///
/// Creates a serialize/deserialize function and a Schema output
class SqliteSerializable {
  /// When `true` (the default), all columns are inserted with `NULL`.
  ///
  /// [Sqlite]'s `#nullable` takes precedence. Defaults to `true`.
  final bool nullable;

  /// Creates a new [SqliteSerializable] instance.
  const SqliteSerializable({
    bool? nullable,
  }) : nullable = nullable ?? true;

  /// An instance of [SqliteSerializable] with all fields set to their default
  /// values.
  static const defaults = SqliteSerializable();
}
