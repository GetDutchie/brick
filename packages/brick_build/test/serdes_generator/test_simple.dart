import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';

@ConnectOfflineFirst()
class Simple extends OfflineFirstModel {
  final int someField;

  Simple(this.someField);
}
