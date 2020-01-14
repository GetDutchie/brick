import 'package:brick_offline_first_abstract/annotations.dart';

final output = r'''''';

@ConnectOfflineFirstWithRest()
class FutureIterableFuture {
  FutureIterableFuture(this.willBeBad);

  final Future<List<Future<String>>> willBeBad;
}
