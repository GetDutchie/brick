import 'package:meta/meta.dart';
import 'package:brick_core/core.dart';
import 'package:brick_sqlite_abstract/db.dart' show InsertTable;
import 'package:brick_sqlite/sqlite.dart';
import 'package:logging/logging.dart';

/// Query models by SQLite primary key, sparing a more expensive on-disk lookup.
///
/// MemoryCacheProvider does not have a type argument due to a build_runner
/// exception: https://github.com/dart-lang/sdk/issues/38309
class MemoryCacheProvider extends Provider<SqliteModel> {
  @protected
  final Logger logger = Logger('MemoryCacheProvider');

  /// The only model classes this instance should track.
  /// As storing objects in memory can be costly elsewhere in the app, models should be
  /// judiciously added to this property.
  final List<Type> managedModelTypes;

  /// Only present to conform to the [Provider] spec.
  @override
  final modelDictionary = null;

  /// A complete hash table of the
  Map<Type, Map<int, SqliteModel>> managedObjects = {};

  /// Is the [type] cached by this provider?
  bool manages(Type type) => managedModelTypes.contains(type);

  /// It is strongly recommended to use this provider with smaller, frequently-accessed
  /// and shared [SqliteModel]s.
  MemoryCacheProvider([
    this.managedModelTypes = const <Type>[],
  ]);

  /// Whether the results of this provider are worth evaluating.
  ///
  /// As this provider is a glorified key/value store, its potential for filtering is limited to
  /// basic lookups such as a single field (primary key).
  /// However, if the provider is extended to support complex [Where] statements in [get],
  /// this method should also be extended.
  bool canFind<_Model extends SqliteModel>([Query? query]) {
    final byPrimaryKey = Where.firstByField(InsertTable.PRIMARY_KEY_FIELD, query?.where);
    return manages(_Model) && byPrimaryKey?.value != null;
  }

  @override
  bool delete<_Model extends SqliteModel>(instance, {query, repository}) {
    if (!manages(_Model)) return false;
    logger.finest('#delete: $_Model, $instance, $query');

    managedObjects[_Model] ??= {};
    managedObjects[_Model]!.remove(instance.primaryKey);
    return true;
  }

  @override
  List<_Model>? get<_Model extends SqliteModel>({query, repository}) {
    if (!manages(_Model)) return null;
    managedObjects[_Model] ??= {};

    logger.finest('#get: $_Model, $query');

    // If this query is searching for a unique identifier, return that specific record
    final byId = Where.firstByField(InsertTable.PRIMARY_KEY_FIELD, query?.where);
    if (byId?.value != null) {
      final object = managedObjects[_Model]![byId!.value] as _Model;
      if (object != null) return [object];
    }

    return null;
  }

  /// Replenish [managedObjects] with new data.
  /// Any one of the [models] with a null `.primaryKey` will not be inserted.
  /// This avoids unexpected null collisions.
  ///
  /// For convenience, the return value is the argument [models],
  /// **not** the complete set of managed [_Model]s.
  /// If the managed models are desired instead, use [get].
  List<_Model> hydrate<_Model extends SqliteModel>(List<_Model> models) {
    if (!manages(_Model)) return models;
    managedObjects[_Model] ??= {};

    models.forEach((instance) {
      if (instance.primaryKey != null) {
        managedObjects[_Model]![instance.primaryKey!] = instance;
      }
    });

    return models;
  }

  /// Destructively wipes all tracked instances. Irreversible.
  void reset() {
    managedObjects = {};
  }

  @override
  _Model? upsert<_Model extends SqliteModel>(instance, {query, repository}) {
    if (!manages(_Model)) return null;
    logger.finest('#upsert: $_Model, $instance, $query');
    hydrate<_Model>([instance]);
    return managedObjects[_Model]![instance.primaryKey] as _Model;
  }
}
