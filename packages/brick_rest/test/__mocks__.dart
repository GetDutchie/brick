import 'package:brick_core/src/model_repository.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class DemoRestModel extends RestModel {
  DemoRestModel(this.name);

  final String name;
}

/// Create [DemoRestModel] from json
Future<DemoRestModel> _$DemoRestModelFromRest(Map<String, dynamic> json) async =>
    DemoRestModel(json['name'] as String);

/// Create json from [DemoRestModel]
Future<Map<String, dynamic>> _$DemoRestModelToRest(DemoRestModel instance) async {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  return val;
}

class DemoRestRequestTransformer extends RestRequestTransformer {
  // A production code base would not forward to another operation
  // but for testing this is convenient
  @override
  RestRequest get delete => get;

  @override
  RestRequest get get {
    final url = () {
      if (query != null && query!.limit != null && query!.limit! > 1) {
        return '/people';
      }

      return '/person';
    }();
    return RestRequest(url: url);
  }

  // A production code base would not forward to another operation
  // but for testing this is convenient
  @override
  RestRequest get upsert => get;

  const DemoRestRequestTransformer(super.query, RestModel? super.instance);
}

/// Construct a [DemoRestModel] for the `RestRepository`
class DemoRestModelAdapter extends RestAdapter<DemoRestModel> {
  @override
  Future<DemoRestModel> fromRest(
    Map<String, dynamic> data, {
    required RestProvider provider,
    ModelRepository<RestModel>? repository,
  }) =>
      _$DemoRestModelFromRest(data);
  @override
  Future<Map<String, dynamic>> toRest(
    DemoRestModel instance, {
    required RestProvider provider,
    ModelRepository<RestModel>? repository,
  }) async =>
      await _$DemoRestModelToRest(instance);

  @override
  final restRequest = DemoRestRequestTransformer.new;
}

final Map<Type, RestAdapter<RestModel>> _restMappings = {
  DemoRestModel: DemoRestModelAdapter(),
};
final restModelDictionary = RestModelDictionary(_restMappings);

MockClient generateClient(String response, {String? requestBody, String? requestMethod}) =>
    MockClient((req) async {
      final matchesRequestBody = req.body == requestBody || requestBody == null;
      final matchesRequestMethod = req.method == requestMethod || requestMethod == null;

      if (matchesRequestMethod && matchesRequestBody) return http.Response(response, 200);

      throw StateError('No response for $response');
    });
