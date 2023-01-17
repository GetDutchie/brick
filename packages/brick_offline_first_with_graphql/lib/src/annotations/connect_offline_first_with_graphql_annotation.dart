import 'package:brick_graphql/brick_graphql.dart' show GraphqlSerializable;
import 'package:brick_sqlite/brick_sqlite.dart' show SqliteSerializable;

/// An annotation used to specify a class to generate code for.
///
/// Clones the annotated class to two files for processing by their respective builders
class ConnectOfflineFirstWithGraphql {
  /// Creates a new [ConnectOfflineFirstWithGraphql] instance.
  const ConnectOfflineFirstWithGraphql({
    this.graphqlConfig,
    this.sqliteConfig,
  });

  /// Configuration for the [GraphqlSerializable] annotation
  final GraphqlSerializable? graphqlConfig;

  /// Configuration for the [SqliteSerializable] annotation
  final SqliteSerializable? sqliteConfig;

  /// An instance of [ConnectOfflineFirstWithGraphql] with all fields set to their default
  /// values.
  static const defaults = ConnectOfflineFirstWithGraphql(
    graphqlConfig: GraphqlSerializable.defaults,
    sqliteConfig: SqliteSerializable.defaults,
  );

  /// Returns a new [ConnectOfflineFirstWithGraphql] instance with fields equal to the
  /// corresponding values in `this`, if not `null`.
  ///
  /// Otherwise, the returned value has the default value as defined in
  /// [defaults].
  ConnectOfflineFirstWithGraphql withDefaults() => ConnectOfflineFirstWithGraphql(
        graphqlConfig: graphqlConfig ?? defaults.graphqlConfig,
        sqliteConfig: sqliteConfig ?? defaults.sqliteConfig,
      );
}
