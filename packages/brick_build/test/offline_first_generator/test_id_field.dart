import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';

@ConnectOfflineFirstWithRest()
class IdField extends OfflineFirstModel {
  @Sqlite(name: "_brick_id")
  final int someField;

  IdField(this.someField);
}
