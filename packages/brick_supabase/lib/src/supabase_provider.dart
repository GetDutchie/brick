import 'package:brick_core/core.dart';
import 'package:brick_supabase/src/query_supabase_transformer.dart';
import 'package:brick_supabase/src/supabase_model.dart';
import 'package:brick_supabase/src/supabase_model_dictionary.dart';
import 'package:brick_supabase/src/supabase_provider_query.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

/// An internal definition for remote requests.
/// In rare cases, a specific `update` or `insert` is preferable to `upsert`;
/// this enum explicitly declares the desired behavior.
enum UpsertMethod {
  /// Translates to a Supabase `.insert`
  insert,

  /// Translates to a Supabase `.update`
  update,

  /// Translates to a Supabase `.upsert`
  upsert,
}

/// Retrieves from a Supabase server
class SupabaseProvider implements Provider<SupabaseModel> {
  /// The client used to connect to the Supabase server.
  /// For some cases, like offline repositories, the offl
  final SupabaseClient client;

  /// The glue between app models and generated adapters.
  @override
  final SupabaseModelDictionary modelDictionary;

  ///
  @protected
  final Logger logger;

  /// Retrieves from a Supabase server
  SupabaseProvider(
    this.client, {
    required this.modelDictionary,
  }) : logger = Logger('SupabaseProvider');

  PostgresChangeFilterType? _compareToFilterParam(Compare compare) {
    switch (compare) {
      case Compare.exact:
        return PostgresChangeFilterType.eq;
      case Compare.contains:
        return PostgresChangeFilterType.inFilter;
      case Compare.greaterThan:
        return PostgresChangeFilterType.gt;
      case Compare.greaterThanOrEqualTo:
        return PostgresChangeFilterType.gte;
      case Compare.lessThan:
        return PostgresChangeFilterType.lt;
      case Compare.lessThanOrEqualTo:
        return PostgresChangeFilterType.lte;
      case Compare.notEqual:
        return PostgresChangeFilterType.neq;
      case Compare.between:
        return null;
      case Compare.doesNotContain:
        return null;
      case Compare.inIterable:
        return null;
    }
  }

  /// Sends a DELETE request method to the endpoint
  @override
  Future<bool> delete<TModel extends SupabaseModel>(
    TModel instance, {
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final tableBuilder = client.from(adapter.supabaseTableName);
    final output = await adapter.toSupabase(instance, provider: this, repository: repository);

    final builder = adapter.uniqueFields.fold(tableBuilder.delete(), (acc, uniqueFieldName) {
      final columnName = adapter.fieldsToSupabaseColumns[uniqueFieldName]!.columnName;
      if (output.containsKey(columnName)) {
        return acc.eq(columnName, output[columnName]);
      }
      return acc;
    });

    final resp = await builder;
    return resp != null;
  }

  @override
  Future<bool> exists<TModel extends SupabaseModel>({
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final queryTransformer =
        QuerySupabaseTransformer<TModel>(modelDictionary: modelDictionary, query: query);
    final builder = queryTransformer.select(client.from(adapter.supabaseTableName));

    final resp = await builder.count(CountOption.exact);
    return resp.count > 0;
  }

  @override
  Future<List<TModel>> get<TModel extends SupabaseModel>({
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final queryTransformer =
        QuerySupabaseTransformer<TModel>(modelDictionary: modelDictionary, query: query);
    final builder = queryTransformer.select(client.from(adapter.supabaseTableName));

    final resp = await queryTransformer.applyQuery(builder);

    return Future.wait<TModel>(
      resp
          .map((r) => adapter.fromSupabase(r, repository: repository, provider: this))
          .toList()
          .cast<Future<TModel>>(),
    );
  }

  /// In almost all cases, use [upsert]. This method is provided for cases when a table's
  /// policy permits inserts without updates.
  Future<TModel> insert<TModel extends SupabaseModel>(
    TModel instance, {
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final output = await adapter.toSupabase(instance, provider: this, repository: repository);

    return await recursiveAssociationUpsert(
      output,
      method: UpsertMethod.insert,
      type: TModel,
      query: query,
      repository: repository,
    ) as TModel;
  }

  /// Convert a query to a [PostgresChangeFilter] for use with [subscribeToRealtime].
  PostgresChangeFilter? queryToPostgresChangeFilter<TModel extends SupabaseModel>(Query query) {
    final adapter = modelDictionary.adapterFor[TModel]!;
    if (query.where?.isEmpty ?? true) return null;
    final condition = query.where!.first;

    final definition = adapter.fieldsToSupabaseColumns[condition.evaluatedField];
    if (definition == null) return null;
    if (definition.association) return null;

    final type = _compareToFilterParam(condition.compare);
    if (type == null) return null;

    return PostgresChangeFilter(
      type: type,
      column: definition.columnName,
      value: condition.value,
    );
  }

  /// Subscribes to realtime updates using
  /// [Supabase channels](https://supabase.com/docs/guides/realtime?queryGroups=language&language=dart).
  /// **This will only work if your Supabase table has realtime enabled.**
  /// Follow [Supabase's documentation](https://supabase.com/docs/guides/realtime?queryGroups=language&language=dart#realtime-api)
  /// to setup your table.
  ///
  /// The resulting stream will also notify for locally-made changes. In an online state, this
  /// will result in duplicate events on the stream - the local copy is updated and notifies
  /// the caller, then the Supabase realtime event is received and notifies the caller again.
  ///
  /// Supabase's channels can
  /// [become expensive quickly](https://supabase.com/docs/guides/realtime/quotas);
  /// please consider scale when utilizing this method.
  ///
  /// [eventType] is the triggering remote event.
  ///
  /// [query] is an optional query to filter the data. The query **must be** one level -
  /// `Query.where('user', Query.exact('name', 'Tom'))` is invalid but `Query.where('name', 'Tom')`
  /// is valid. The [Compare] operator is limited to a [PostgresChangeFilterType] equivalent.
  /// See [_compareToFilterParam] for a precise breakdown.
  ///
  /// [RealtimeChannel.subscribe] is invoked before the [RealtimeChannel] is returned to the caller.
  RealtimeChannel subscribeToRealtime<TModel extends SupabaseModel>({
    required void Function(PostgresChangePayload payload) callback,
    PostgresChangeEvent eventType = PostgresChangeEvent.all,
    Query? query,
    String schema = 'public',
  }) {
    final adapter = modelDictionary.adapterFor[TModel]!;
    return client
        .channel(adapter.supabaseTableName)
        .onPostgresChanges(
          event: eventType,
          schema: schema,
          table: adapter.supabaseTableName,
          filter: queryToPostgresChangeFilter<TModel>(query ?? const Query()),
          callback: callback,
        )
        .subscribe();
  }

  /// In almost all cases, use [upsert]. This method is provided for cases when a table's
  /// policy permits updates without inserts.
  Future<TModel> update<TModel extends SupabaseModel>(
    TModel instance, {
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final output = await adapter.toSupabase(instance, provider: this, repository: repository);

    return await recursiveAssociationUpsert(
      output,
      method: UpsertMethod.update,
      type: TModel,
      query: query,
      repository: repository,
    ) as TModel;
  }

  /// Association models are upserted recursively before the requested instance is upserted.
  /// Because it's unknown if there has been any change from the local association to the remote
  /// association, all associations and their associations are upserted on a parent's upsert.
  ///
  /// For example, given model `Room` has association `Bed` and `Bed` has association `Pillow`,
  /// when `Room` is upserted, `Pillow` is upserted and then `Bed` is upserted.
  @override
  Future<TModel> upsert<TModel extends SupabaseModel>(
    TModel instance, {
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final output = await adapter.toSupabase(instance, provider: this, repository: repository);
    final providerQuery = query?.providerQueries[SupabaseProvider] as SupabaseProviderQuery?;

    return await recursiveAssociationUpsert(
      output,
      method: providerQuery?.upsertMethod ?? UpsertMethod.upsert,
      type: TModel,
      query: query,
      repository: repository,
    ) as TModel;
  }

  /// Used by [recursiveAssociationUpsert], this performs the upsert to Supabase
  /// and selects the model's fields in the response.
  @protected
  Future<SupabaseModel> upsertByType(
    Map<String, dynamic> serializedInstance, {
    UpsertMethod method = UpsertMethod.upsert,
    required Type type,
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    assert(modelDictionary.adapterFor.containsKey(type), '$type not found in the model dictionary');

    final adapter = modelDictionary.adapterFor[type]!;

    final queryTransformer =
        QuerySupabaseTransformer(adapter: adapter, modelDictionary: modelDictionary, query: query);

    final builderFilter = () {
      switch (method) {
        case UpsertMethod.insert:
          return client.from(adapter.supabaseTableName).insert(serializedInstance);
        case UpsertMethod.update:
          return client.from(adapter.supabaseTableName).update(serializedInstance);
        case UpsertMethod.upsert:
          return client
              .from(adapter.supabaseTableName)
              .upsert(serializedInstance, onConflict: adapter.onConflict);
      }
    }();

    final builder = adapter.uniqueFields.fold(builderFilter, (acc, uniqueFieldName) {
      final columnName = adapter.fieldsToSupabaseColumns[uniqueFieldName]!.columnName;
      if (serializedInstance.containsKey(columnName)) {
        return acc.eq(columnName, serializedInstance[columnName]);
      }
      return acc;
    });
    final resp = await builder.select(queryTransformer.selectFields).limit(1).maybeSingle();

    if (resp == null) {
      throw StateError('Upsert of $type failed');
    }

    return adapter.fromSupabase(resp, repository: repository, provider: this);
  }

  /// Discover all SupabaseModel-like associations of a serialized instance and
  /// upsert them recursively before the requested instance is upserted.
  @protected
  Future<SupabaseModel> recursiveAssociationUpsert(
    Map<String, dynamic> serializedInstance, {
    UpsertMethod method = UpsertMethod.upsert,
    required Type type,
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    assert(modelDictionary.adapterFor.containsKey(type), '$type not found in the model dictionary');

    final adapter = modelDictionary.adapterFor[type]!;
    final associations = adapter.fieldsToSupabaseColumns.values
        .where((a) => a.association && a.associationType != null);

    for (final association in associations) {
      if (!serializedInstance.containsKey(association.columnName)) {
        continue;
      }

      if (serializedInstance[association.columnName] is! Map) {
        continue;
      }

      await recursiveAssociationUpsert(
        Map<String, dynamic>.from(serializedInstance[association.columnName]),
        method: method,
        type: association.associationType!,
        query: query,
        repository: repository,
      );
      serializedInstance.remove(association.columnName);
    }

    return await upsertByType(
      serializedInstance,
      method: method,
      type: type,
      query: query,
      repository: repository,
    );
  }
}
