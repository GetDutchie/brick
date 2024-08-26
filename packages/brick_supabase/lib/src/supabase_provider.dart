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

    final queryTransformer =
        QuerySupabaseTransformer<TModel>(modelDictionary: modelDictionary, query: query);

    final builder = adapter.uniqueFields.fold(tableBuilder.delete(), (acc, uniqueFieldName) {
      final columnName = adapter.fieldsToSupabaseColumns[uniqueFieldName]!.columnName;
      if (output.containsKey(columnName)) {
        return acc.eq(columnName, output[columnName]);
      }
      return acc;
    });

    final resp = await builder.select(queryTransformer.selectFields).limit(1).maybeSingle();
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
  /// * `'limit'` e.g. `{'limit': 10}`
  /// * `'limitByReferencedTable'` forwards to Supabase's `referencedTable` property https://supabase.com/docs/reference/dart/limit
  /// * `'orderBy'` Use field names not column names and always specify direction.
  /// For example, given a `final DateTime createdAt;` field: `{'orderBy': 'createdAt ASC'}`.
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
    return await _recursiveAssociationUpsert(
      instance,
      type: TModel,
      query: query,
      repository: repository,
    ) as TModel;
  }

  Future<SupabaseModel> _upsertByType(
    SupabaseModel instance, {
    required Type type,
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    assert(modelDictionary.adapterFor.containsKey(type));

    final adapter = modelDictionary.adapterFor[type]!;
    final output = await adapter.toSupabase(instance, provider: this, repository: repository);

    final queryTransformer =
        QuerySupabaseTransformer(adapter: adapter, modelDictionary: modelDictionary, query: query);

    final builder = adapter.uniqueFields.fold(client.from(adapter.supabaseTableName).upsert(output),
        (acc, uniqueFieldName) {
      final columnName = adapter.fieldsToSupabaseColumns[uniqueFieldName]!.columnName;
      if (output.containsKey(columnName)) {
        return acc.eq(columnName, output[columnName]);
      }
      return acc;
    });
    final resp = await builder.select(queryTransformer.selectFields).limit(1).maybeSingle();

    if (resp == null) {
      throw StateError('Upsert of $instance failed');
    }

    return adapter.fromSupabase(resp, repository: repository, provider: this);
  }

  Future<SupabaseModel> _recursiveAssociationUpsert(
    SupabaseModel instance, {
    required Type type,
    Query? query,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    assert(modelDictionary.adapterFor.containsKey(type));

    final adapter = modelDictionary.adapterFor[type]!;
    final associations = adapter.fieldsToSupabaseColumns.values
        .where((a) => a.association && a.associationType != null);

    for (final association in associations) {
      await _recursiveAssociationUpsert(
        instance,
        type: association.associationType!,
        query: query,
        repository: repository,
      );
    }
    return await _upsertByType(instance, type: type, query: query, repository: repository);
  }
}
