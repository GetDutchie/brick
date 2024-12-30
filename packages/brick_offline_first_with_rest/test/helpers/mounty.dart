// ignore_for_file: avoid_field_initializers_in_const_classes

part of '__mocks__.dart';

class MountyRequestTransformer extends RestRequestTransformer {
  @override
  final get = const RestRequest(url: '/mounties');
  @override
  RestRequest? get upsert => get;
  const MountyRequestTransformer(super.query, super.instance);
}

class Mounty extends OfflineFirstWithRestModel {
  final String? name;

  Mounty({
    this.name,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is Mounty && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
