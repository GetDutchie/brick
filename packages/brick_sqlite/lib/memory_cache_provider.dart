import 'package:brick_core/core.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/models/sqlite_model.dart';
import 'package:brick_sqlite/src/sqlite_adapter.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// Query models by SQLite primary key, sparing a more expensive on-disk lookup.
///
/// MemoryCacheProvider does not have a type argument due to a build_runner
/// exception: https://github.com/dart-lang/sdk/issues/38309
class MemoryCacheProvider<TProviderModel extends SqliteModel> extends Provider<TProviderModel> {
  ///
  @protected
  final logger = Logger('MemoryCacheProvider');

  /// The only model classes this instance should track.
  /// As storing objects in memory can be costly elsewhere in the app, models should be
  /// judiciously added to this property.
  final List<Type> managedModelTypes;

  /// Only present to conform to the [Provider] spec.
  @override
  final modelDictionary = _MemoryCacheModelDictionary();

  /// A complete hash table of the
  Map<Type, Map<int, TProviderModel>> managedObjects = {};

  /// Is the [type] cached by this provider?
  bool manages(Type type) => managedModelTypes.contains(type);

  /// It is strongly recommended to use this provider with smaller, frequently-accessed
  /// and shared [TProviderModel]s.
  MemoryCacheProvider([
    this.managedModelTypes = const <Type>[],
  ]);

  /// Whether the results of this provider are worth evaluating.
  ///
  /// As this provider is a glorified key/value store, its potential for filtering is limited to
  /// basic lookups such as a single field (primary key).
  /// However, if the provider is extended to support complex [Where] statements in [get],
  /// this method should also be extended.
  bool canFind<TModel extends TProviderModel>([Query? query]) {
    final byPrimaryKey = Where.firstByField(InsertTable.PRIMARY_KEY_FIELD, query?.where);
    return manages(TModel) && byPrimaryKey?.value != null;
  }

  @override
  bool delete<TModel extends TProviderModel>(
    TModel instance, {
    Query? query,
    ModelRepository<TProviderModel>? repository,
  }) {
    if (!manages(TModel)) return false;
    logger.finest('#delete: $TModel, $instance, $query');

    managedObjects[TModel] ??= {};
    managedObjects[TModel]!.remove(instance.primaryKey);
    return true;
  }

  @override
  List<TModel>? get<TModel extends TProviderModel>({
    Query? query,
    ModelRepository<TProviderModel>? repository,
  }) {
    if (!manages(TModel)) return null;
    managedObjects[TModel] ??= {};

    logger.finest('#get: $TModel, $query');

    // If this query is searching for a unique identifier, return that specific record
    final byId = Where.firstByField(InsertTable.PRIMARY_KEY_FIELD, query?.where);
    if (byId?.value != null) {
      final object = managedObjects[TModel]?[byId!.value];
      if (object != null) return [object as TModel];
    }

    return null;
  }

  /// Replenish [managedObjects] with new data.
  /// Any one of the [models] with a null `.primaryKey` will not be inserted.
  /// This avoids unexpected null collisions.
  ///
  /// For convenience, the return value is the argument [models],
  /// **not** the complete set of managed [TModel]s.
  /// If the managed models are desired instead, use [get].
  List<TModel> hydrate<TModel extends TProviderModel>(List<TModel> models) {
    if (!manages(TModel)) return models;
    managedObjects[TModel] ??= {};

    for (final instance in models) {
      if (instance.primaryKey != null) {
        managedObjects[TModel]![instance.primaryKey!] = instance;
      }
    }

    return models;
  }

  /// Destructively wipes all tracked instances. Irreversible.
  void reset() {
    managedObjects = {};
  }

  @override
  TModel? upsert<TModel extends TProviderModel>(
    TModel instance, {
    Query? query,
    ModelRepository<TProviderModel>? repository,
  }) {
    if (!manages(TModel)) return null;
    logger.finest('#upsert: $TModel, $instance, $query');
    hydrate<TModel>([instance]);
    return managedObjects[TModel]![instance.primaryKey]! as TModel;
  }
}

class _MemoryCacheModelDictionary extends ModelDictionary<SqliteModel, SqliteAdapter<SqliteModel>> {
  _MemoryCacheModelDictionary() : super({});
}
