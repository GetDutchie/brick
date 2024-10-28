import 'package:brick_core/query.dart';
import 'package:brick_supabase/src/query_supabase_transformer.dart';
import 'package:brick_supabase/src/supabase_model.dart';
import 'package:brick_supabase/src/supabase_model_dictionary.dart';

class SupabaseRequest<TModel extends SupabaseModel> {
  /// If `fields` are not provided, they will try to be inferred using the
  /// [SupabaseMockServer]'s `modelDictionary`.
  final String? fields;

  final String? filter;

  final int? limit;

  final String? requestMethod;

  /// If a `tableName` is not provided, it will try to be inferred using the
  /// [SupabaseMockServer]'s `modelDictionary` based on the
  /// `SupabaseAdapter`'s `supabaseTableName`.
  final String? tableName;

  SupabaseRequest({
    this.tableName,
    this.fields,
    this.filter,
    this.limit,
    this.requestMethod = 'GET',
  });

  Uri toUri(SupabaseModelDictionary? modelDictionary) {
    final generatedFields = modelDictionary != null
        ? SupabaseRequest.fieldsFromDictionary<TModel>(modelDictionary)
        : fields;
    final generatedTableName =
        modelDictionary != null ? modelDictionary.adapterFor[TModel]?.supabaseTableName : tableName;

    if (requestMethod == 'DELETE') {
      final url = '/rest/v1/$generatedTableName${filter != null ? '?$filter&' : '?'}';
      return Uri.parse(url);
    }

    final url =
        '/rest/v1/$generatedTableName${filter != null ? '?$filter&' : '?'}select=${Uri.encodeComponent(generatedFields ?? '')}${limit != null ? '&limit=$limit' : ''}';
    return Uri.parse(url);
  }

  /// This provides a convenience method to generate [fields] as the
  /// [SupabaseProvider] would generate them.
  static String fieldsFromDictionary<TModel extends SupabaseModel>(
    SupabaseModelDictionary modelDictionary, {
    Query? query,
  }) {
    final transformer =
        QuerySupabaseTransformer<TModel>(modelDictionary: modelDictionary, query: query);
    return transformer.selectFields;
  }
}
