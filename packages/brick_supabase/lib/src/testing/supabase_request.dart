import 'package:brick_core/query.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase/src/query_supabase_transformer.dart';
import 'package:brick_supabase/src/testing/supabase_mock_server.dart';
import 'package:brick_supabase/testing.dart';

/// Construct a request for Supabase data. The primary purpose of this class is to
/// DRY code for URL requests to the [SupabaseMockServer]. For example:
/// `final req = SupabaseRequest<MyModel>();`
class SupabaseRequest<TModel extends SupabaseModel> {
  /// If `fields` are not provided, they will try to be inferred using the
  /// [SupabaseMockServer]'s `modelDictionary`.
  final String? fields;

  /// A PostgREST-style filter, such as `id=eq.1`
  final String? filter;

  ///
  final int? limit;

  ///
  final bool realtime;

  /// An HTTP request method, e.g. `GET`, `POST`, `PUT`, `DELETE`
  final String? requestMethod;

  /// If a `tableName` is not provided, it will try to be inferred using the
  /// [SupabaseMockServer]'s `modelDictionary` based on the
  /// `SupabaseAdapter`'s `supabaseTableName`.
  final String? tableName;

  /// Construct a request for Supabase data. The primary purpose of this class is to
  /// DRY code for URL requests to the [SupabaseMockServer]. For example:
  /// `final req = SupabaseRequest<MyModel>();`
  const SupabaseRequest({
    this.tableName,
    this.fields,
    this.filter,
    this.limit,
    this.realtime = false,
    this.requestMethod = 'GET',
  });

  /// Convert the request to a PostgREST URL
  Uri toUri(SupabaseModelDictionary? modelDictionary) {
    final generatedFields = modelDictionary != null
        ? SupabaseRequest.fieldsFromDictionary<TModel>(modelDictionary)
        : fields;
    final generatedTableName =
        modelDictionary != null ? modelDictionary.adapterFor[TModel]?.supabaseTableName : tableName;

    final prefix = realtime ? 'realtime' : 'rest';

    if (requestMethod == 'DELETE') {
      final url = '/$prefix/v1/$generatedTableName${filter != null ? '?$filter&' : '?'}';
      return Uri.parse(url);
    }

    final url =
        '/$prefix/v1/$generatedTableName${filter != null ? '?$filter&' : '?'}select=${Uri.encodeComponent(generatedFields ?? '')}${limit != null ? '&limit=$limit' : ''}';
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
