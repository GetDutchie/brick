import 'package:brick_offline_first/offline_first_with_rest.dart';

import 'package:brick_offline_first_example/app/models/hat.dart';

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
