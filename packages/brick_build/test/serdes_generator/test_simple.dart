import '../__helpers__.dart';

@ConnectAnnotation()
class Simple extends OfflineFirstModel {
  final int someField;

  Simple(this.someField);
}
