import 'package:brick_rest/rest.dart' show RestSerializable;
import 'package:brick_sqlite_abstract/annotations.dart';

/// An annotation used to specify a class to generate code for.
///
/// Clones the annotated class to two files for processing by their respective builders
class ConnectOfflineFirst {
  /// Creates a new [ConnectOfflineFirst] instance.
  const ConnectOfflineFirst({
    this.restConfig,
    this.sqliteConfig,
  });

  /// Configuration for the [RestSerializable] annotation
  final RestSerializable restConfig;

  /// Configuration for the [SqliteSerializable] annotation
  final SqliteSerializable sqliteConfig;

  /// An instance of [ConnectOfflineFirst] with all fields set to their default
  /// values.
  static const defaults = ConnectOfflineFirst(
    restConfig: RestSerializable.defaults,
    sqliteConfig: SqliteSerializable.defaults,
  );

  /// Returns a new [ConnectOfflineFirst] instance with fields equal to the
  /// corresponding values in `this`, if not `null`.
  ///
  /// Otherwise, the returned value has the default value as defined in
  /// [defaults].
  ConnectOfflineFirst withDefaults() => ConnectOfflineFirst(
        restConfig: restConfig ?? defaults.restConfig,
        sqliteConfig: sqliteConfig ?? defaults.sqliteConfig,
      );
}
