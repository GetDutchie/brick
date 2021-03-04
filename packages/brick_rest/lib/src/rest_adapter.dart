import 'package:brick_core/core.dart';
import 'package:brick_rest/src/rest_provider.dart';
import 'package:brick_rest/src/rest_model.dart';

/// Constructors that convert app models to and from REST
abstract class RestAdapter<_Model extends Model> implements Adapter<_Model> {
  /// Retrieves data under this key when deserializing from REST
  String? get fromKey;

  /// Submits data under this key when serializing to REST
  String? get toKey;

  Future<_Model> fromRest(
    Map<String, dynamic> data, {
    RestProvider provider,
    ModelRepository<RestModel> repository,
  });
  Future<Map<String, dynamic>> toRest(
    _Model instance, {
    RestProvider provider,
    ModelRepository<RestModel> repository,
  });

  /// The endpoint path to access provided a query. Must include a leading slash.
  String? restEndpoint({Query query, _Model instance});
}
