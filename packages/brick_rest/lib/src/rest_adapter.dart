import 'package:brick_core/core.dart';
import 'package:brick_rest/src/rest_request_transformer.dart';
import 'package:brick_rest/src/rest_provider.dart';
import 'package:brick_rest/src/rest_model.dart';

class _DefaultRestTransformer extends RestRequestTransformer {
  const _DefaultRestTransformer(Query? query, RestModel? instance) : super(null, null);
}

/// Constructors that convert app models to and from REST
abstract class RestAdapter<TModel extends RestModel> implements Adapter<TModel> {
  Future<TModel> fromRest(
    Map<String, dynamic> input, {
    required RestProvider provider,
    ModelRepository<RestModel>? repository,
  });

  /// The endpoint path to access provided a query. Must include a leading slash.
  RestRequestTransformer Function(Query?, TModel?)? get restRequest => _DefaultRestTransformer.new;

  Future<Map<String, dynamic>> toRest(
    TModel input, {
    required RestProvider provider,
    ModelRepository<RestModel>? repository,
  });
}
