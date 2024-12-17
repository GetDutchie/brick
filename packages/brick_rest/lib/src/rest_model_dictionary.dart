import 'package:brick_core/core.dart';
import 'package:brick_rest/src/rest_adapter.dart';
import 'package:brick_rest/src/rest_model.dart';

/// Associates app models with their [RestAdapter]
class RestModelDictionary extends ModelDictionary<RestModel, RestAdapter<RestModel>> {
  /// Associates app models with their [RestAdapter]
  const RestModelDictionary(super.adapterFor);
}
