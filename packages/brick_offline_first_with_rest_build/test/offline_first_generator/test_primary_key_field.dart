import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';

@ConnectOfflineFirstWithRest()
class PrimaryKeyField extends OfflineFirstModel {
  final int primaryKey;

  PrimaryKeyField(this.primaryKey);
}
