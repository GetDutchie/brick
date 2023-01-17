import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:brick_rest/brick_rest.dart';

class DemoRestModel extends RestModel {
  DemoRestModel(this.name);

  final String name;
}

/// Create [DemoRestModel] from json
Future<DemoRestModel> _$DemoRestModelFromRest(Map<String, dynamic> json) async {
  return DemoRestModel(json['name'] as String);
}

/// Create json from [DemoRestModel]
Future<Map<String, dynamic>> _$DemoRestModelToRest(DemoRestModel instance) async {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  return val;
}

/// Construct a [DemoRestModel] for the [RestRepository]
class DemoRestModelAdapter extends RestAdapter<DemoRestModel> {
  @override
  Future<DemoRestModel> fromRest(data, {required provider, repository}) =>
      _$DemoRestModelFromRest(data);
  @override
  Future<Map<String, dynamic>> toRest(instance, {required provider, repository}) async =>
      await _$DemoRestModelToRest(instance);
  @override
  String restEndpoint({query, instance}) {
    if (query != null && query.providerArgs['limit'] != null && query.providerArgs['limit'] > 1) {
      return '/people';
    }

    return '/person';
  }

  @override
  final fromKey = null;
  @override
  final toKey = null;
}

final Map<Type, RestAdapter<RestModel>> _restMappings = {
  DemoRestModel: DemoRestModelAdapter(),
};
final restModelDictionary = RestModelDictionary(_restMappings);

MockClient generateClient(String response, {String? requestBody, String? requestMethod}) {
  return MockClient((req) async {
    final matchesRequestBody = req.body == requestBody || requestBody == null;
    final matchesRequestMethod = req.method == requestMethod || requestMethod == null;

    if (matchesRequestMethod && matchesRequestBody) return http.Response(response, 200);

    throw StateError('No response for $response');
  });
}
