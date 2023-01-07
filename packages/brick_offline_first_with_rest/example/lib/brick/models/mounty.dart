import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_offline_first_with_rest_example/brick/models/hat.dart';
import 'package:brick_rest/brick_rest.dart';

@ConnectOfflineFirstWithRest(restConfig: RestSerializable(endpoint: "=> '/mounties'"))
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
