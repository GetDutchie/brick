import 'package:test/test.dart';
import '__mocks__.dart';

class DemoSimpleStore extends SingleProviderRepository<DemoModel> {
  @override
  final DemoProvider provider;

  DemoSimpleStore(this.provider) : super(provider);

  DemoProvider get testableProvider => provider;
}

void main() {
  group('SingleProviderRepository', () {
    final provider = DemoProvider(modelDictionary);
    final store = DemoSimpleStore(provider);

    test('#provider', () {
      expect(store.provider, provider);
    });

    test('#get', () async {
      final storeOnce = await store.get();
      final providerOnce = await provider.get();
      expect(storeOnce.first.name, providerOnce.first.name);
    });
  });
}
