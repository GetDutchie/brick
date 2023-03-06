import 'package:brick_core/core.dart';
import 'package:brick_rest/src/rest_request_transformer.dart';
import 'package:brick_rest/src/rest_provider.dart';
import 'package:brick_rest/src/rest_model.dart';

class _DefaultRestTransformer<TModel extends RestModel> extends RestRequestTransformer<TModel> {
  const _DefaultRestTransformer(Query? query, TModel? instance) : super(null, null);
}

/// Constructors that convert app models to and from REST
abstract class RestAdapter<TModel extends RestModel> implements Adapter<TModel> {
  Future<TModel> fromRest(
    Map<String, dynamic> input, {
    required RestProvider provider,
    ModelRepository<RestModel>? repository,
  });

  /// The endpoint path to access provided a query. Must include a leading slash.
  RestRequestTransformer<TModel> Function(Query?, TModel?)? get restRequest =>
      _DefaultRestTransformer<TModel>.new;

  Future<Map<String, dynamic>> toRest(
    TModel input, {
    required RestProvider provider,
    ModelRepository<RestModel>? repository,
  });
}
