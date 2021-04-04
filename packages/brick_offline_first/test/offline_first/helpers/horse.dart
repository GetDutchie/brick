part of '__mocks__.dart';

class Horse extends OfflineFirstWithRestModel {
  final String? name;

  final List<Mounty> mounties;

  Horse({
    this.name,
    this.mounties = const <Mounty>[],
  });
}
