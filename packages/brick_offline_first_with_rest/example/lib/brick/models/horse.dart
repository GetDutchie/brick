import 'package:brick_offline_first/offline_first_with_rest.dart';

import 'package:brick_offline_first_example/brick/models/mounty.dart';

@ConnectOfflineFirstWithRest()
class Horse extends OfflineFirstWithRestModel {
  final String? name;

  final List<Mounty>? mounties;

  Horse({
    this.name,
    this.mounties,
  });
}
