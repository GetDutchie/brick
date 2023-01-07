import 'package:brick_rest/brick_rest.dart' show RestSerializable;
import 'package:brick_sqlite/brick_sqlite.dart';

/// An annotation used to specify a class to generate code for.
///
/// Clones the annotated class to two files for processing by their respective builders
class ConnectOfflineFirstWithRest {
  /// Creates a new [ConnectOfflineFirstWithRest] instance.
  const ConnectOfflineFirstWithRest({
    this.restConfig,
    this.sqliteConfig,
  });

  /// Configuration for the [RestSerializable] annotation
  final RestSerializable? restConfig;

  /// Configuration for the [SqliteSerializable] annotation
  final SqliteSerializable? sqliteConfig;

  /// An instance of [ConnectOfflineFirstWithRest] with all fields set to their default
  /// values.
  static const defaults = ConnectOfflineFirstWithRest(
    restConfig: RestSerializable.defaults,
    sqliteConfig: SqliteSerializable.defaults,
  );

  /// Returns a new [ConnectOfflineFirstWithRest] instance with fields equal to the
  /// corresponding values in `this`, if not `null`.
  ///
  /// Otherwise, the returned value has the default value as defined in
  /// [defaults].
  ConnectOfflineFirstWithRest withDefaults() => ConnectOfflineFirstWithRest(
        restConfig: restConfig ?? defaults.restConfig,
        sqliteConfig: sqliteConfig ?? defaults.sqliteConfig,
      );
}
