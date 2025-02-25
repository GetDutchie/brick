import 'package:test/test.dart';

import '__mocks__.dart';

void main() {
  group('Provider', () {
    final provider = DemoProvider(modelDictionary);

    test('#get', () async {
      final res = await provider.get();
      expect(res, isList);
      expect(res.first, const TypeMatcher<DemoModel>());
      expect(res.first.name, 'Thomas');
    });

    test('#upsert', () {
      final res = provider.upsert(DemoModel('Thomas'));
      expect(res, isTrue);
    });

    test('#modelDictionary', () {
      expect(provider.modelDictionary.adapterFor.containsKey(DemoModel), isTrue);
      expect(provider.modelDictionary.adapterFor[DemoModel], const TypeMatcher<DemoAdapter>());
      expect(provider.modelDictionary.adapterFor, mappings);
    });
  });
}
