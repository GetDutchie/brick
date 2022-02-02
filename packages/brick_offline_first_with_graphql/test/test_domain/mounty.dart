part of '__mocks__.dart';

class Mounty extends OfflineFirstWithGraphqlModel {
  final String? name;

  Mounty({
    this.name,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is Mounty && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
