import 'package:brick_core/query.dart';
import 'package:brick_rest/src/rest_provider.dart';
import 'package:brick_rest/src/rest_request.dart';

class RestProviderQuery extends ProviderQuery<RestProvider> {
  final RestRequest? request;

  const RestProviderQuery({
    this.request,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      if (request != null) 'request': request?.toJson(),
    };
  }
}
