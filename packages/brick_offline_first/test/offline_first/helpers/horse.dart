part of '__mocks__.dart';

class Horse extends OfflineFirstWithTestModel {
  final String? name;

  final List<Mounty> mounties;

  final Owner? owner;

  Horse({this.name, this.mounties = const <Mounty>[], this.owner});
}
