import 'package:brick_core/core.dart';
import 'package:brick_supabase/src/query_supabase_transformer.dart';
import 'package:brick_supabase/src/supabase_model_dictionary.dart';
import 'package:brick_supabase_abstract/brick_supabase_abstract.dart' hide Supabase;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

/// Retrieves from an HTTP endpoint
class SupabaseProvider implements Provider<SupabaseModel> {
  /// A fully-qualified URL
  final String baseEndpoint;

  final SupabaseClient client;

  /// The glue between app models and generated adapters.
  @override
  final SupabaseModelDictionary modelDictionary;

  @protected
  final Logger logger;

  SupabaseProvider(
    this.baseEndpoint, {
    required this.client,
    required this.modelDictionary,
  }) : logger = Logger('SupabaseProvider');

  /// Sends a DELETE request method to the endpoint
  @override
  Future<bool> delete<TModel extends SupabaseModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final tableBuilder = client.from(adapter.tableName);
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

    final resp = await builder.select(queryTransformer.selectQuery).limit(1).maybeSingle();
    return resp == null;
  }

  @override
  Future<bool> exists<TModel extends SupabaseModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final queryTransformer =
        QuerySupabaseTransformer<TModel>(modelDictionary: modelDictionary, query: query);
    final builder = queryTransformer.select(client.from(adapter.tableName));

    final resp = await builder.count(CountOption.exact);
    return resp.count > 0;
  }

  @override
  Future<List<TModel>> get<TModel extends SupabaseModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final queryTransformer =
        QuerySupabaseTransformer<TModel>(modelDictionary: modelDictionary, query: query);
    final builder = queryTransformer.select(client.from(adapter.tableName));

    final resp = await builder;

    return resp
        .map((r) => adapter.fromSupabase(r, repository: repository, provider: this))
        .toList()
        .cast<TModel>();
  }

  @override
  Future<TModel> upsert<TModel extends SupabaseModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final output = await adapter.toSupabase(instance, provider: this, repository: repository);

    final queryTransformer =
        QuerySupabaseTransformer<TModel>(modelDictionary: modelDictionary, query: query);

    final builder = adapter.uniqueFields.fold(client.from(adapter.tableName).upsert(output),
        (acc, uniqueFieldName) {
      final columnName = adapter.fieldsToSupabaseColumns[uniqueFieldName]!.columnName;
      if (output.containsKey(columnName)) {
        return acc.eq(columnName, output[columnName]);
      }
      return acc;
    });
    final resp = await builder.select(queryTransformer.selectQuery).limit(1).maybeSingle();

    if (resp == null) {
      throw StateError('Upsert of $instance failed');
    }

    return adapter.fromSupabase(resp, repository: repository, provider: this) as TModel;
  }
}
