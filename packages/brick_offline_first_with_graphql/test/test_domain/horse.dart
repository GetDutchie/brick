part of '__mocks__.dart';

class Horse extends OfflineFirstWithGraphqlModel {
  final String? name;

  final List<Mounty> mounties;

  Horse({
    this.name,
    this.mounties = const <Mounty>[],
  });
}
