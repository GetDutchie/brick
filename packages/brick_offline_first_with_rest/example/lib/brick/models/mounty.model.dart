import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_offline_first_with_rest_example/brick/models/hat.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_core/core.dart';

class MountyRequest extends RestRequestTransformer {
  final get = RestRequest(url: '/mounties');

  RestRequest? get upsert => get;

  MountyRequest(Query? query, Model? instance) : super(query, instance);
}

@ConnectOfflineFirstWithRest(restConfig: RestSerializable(requestTransformer: MountyRequest.new))
class Mounty extends OfflineFirstWithRestModel {
  final String? name;

  final String? email;

  final Hat? hat;

  Mounty({
    this.name,
    this.email,
    this.hat,
  });
}
