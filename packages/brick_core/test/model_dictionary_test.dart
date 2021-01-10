import 'package:test/test.dart';
import '__mocks__.dart';

void main() {
  group('ModelDictionary', () {
    test('#adapterFor', () {
      expect(modelDictionary.adapterFor, mappings);
      expect(modelDictionary.adapterFor.containsKey(DemoModel), isTrue);
    });
  });
}
