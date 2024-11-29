import 'package:brick_core/core.dart';
import 'package:brick_supabase/src/query_supabase_transformer.dart';
import 'package:brick_supabase/src/supabase_model.dart';
import 'package:brick_supabase/src/supabase_model_dictionary.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

/// Retrieves from an HTTP endpoint
class SupabaseProvider implements Provider<SupabaseModel> {
  final SupabaseClient client;

  /// The glue between app models and generated adapters.
  @override
  final SupabaseModelDictionary modelDictionary;

  @protected
  final Logger logger;

  SupabaseProvider(
    this.client, {
    required this.modelDictionary,
  }) : logger = Logger('SupabaseProvider');

  /// Sends a DELETE request method to the endpoint
  @override
  Future<bool> delete<TModel extends SupabaseModel>(instance, {query, repository}) async {
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
  Future<bool> exists<TModel extends SupabaseModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final queryTransformer =
        QuerySupabaseTransformer<TModel>(modelDictionary: modelDictionary, query: query);
    final builder = queryTransformer.select(client.from(adapter.supabaseTableName));

    final resp = await builder.count(CountOption.exact);
    return resp.count > 0;
  }

  /// [Query]'s `providerArgs` can extend the [get] functionality:
  /// * `'limitByReferencedTable'` forwards to Supabase's `referencedTable` property https://supabase.com/docs/reference/dart/limit
  /// If the column cannot be found for the first value before a space, the value is left unchanged.
  /// * `'orderByReferencedTable'` forwards to Supabase's `referencedTable` property https://supabase.com/docs/reference/dart/order
  @override
  Future<List<TModel>> get<TModel extends SupabaseModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final queryTransformer =
        QuerySupabaseTransformer<TModel>(modelDictionary: modelDictionary, query: query);
    final builder = queryTransformer.select(client.from(adapter.supabaseTableName));

    final resp = await queryTransformer.applyProviderArgs(builder);

    return Future.wait<TModel>(
      resp
          .map((r) => adapter.fromSupabase(r, repository: repository, provider: this))
          .toList()
          .cast<Future<TModel>>(),
    );
  }

  /// Association models are upserted recursively before the requested instance is upserted.
  /// Because it's unknown if there has been any change from the local association to the remote
  /// association, all associations and their associations are upserted on a parent's upsert.
  ///
  /// For example, given model `Room` has association `Bed` and `Bed` has association `Pillow`,
  /// when `Room` is upserted, `Pillow` is upserted and then `Bed` is upserted.
  @override
  Future<TModel> upsert<TModel extends SupabaseModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final output = await adapter.toSupabase(instance, provider: this, repository: repository);

    return await recursiveAssociationUpsert(
      output,
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
    required Type type,
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    assert(modelDictionary.adapterFor.containsKey(type));

    final adapter = modelDictionary.adapterFor[type]!;

    final queryTransformer =
        QuerySupabaseTransformer(adapter: adapter, modelDictionary: modelDictionary, query: query);

    final builder = adapter.uniqueFields.fold(
        client
            .from(adapter.supabaseTableName)
            .upsert(serializedInstance, onConflict: adapter.onConflict), (acc, uniqueFieldName) {
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
    required Type type,
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    assert(modelDictionary.adapterFor.containsKey(type));

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
        type: association.associationType!,
        query: query,
        repository: repository,
      );
      serializedInstance.remove(association.columnName);
    }

    return await upsertByType(
      serializedInstance,
      type: type,
      query: query,
      repository: repository,
    );
  }
}
