import 'package:brick_graphql/brick_graphql.dart';
import 'package:test/test.dart';

import '__helpers__/demo_model.dart';
import '__helpers__/stub_response.dart';
import '__mocks__.dart';

GraphqlProvider generateProvider(
  dynamic response, {
  List<String>? errors,
  String? variablesNamespace,
}) =>
    GraphqlProvider(
      modelDictionary: dictionary,
      link: stubResponse({'upsertPerson': response}, errors: errors),
      variableNamespace: variablesNamespace,
    );

void main() {
  group('GraphqlProvider', () {
    group('#delete', () {
      test('success', () async {
        final provider = generateProvider({'full_name': 'Thomas'});

        final instance = DemoModel(name: 'Guy');
        final didDelete = await provider.delete<DemoModel>(instance);
        expect(didDelete, true);
      });

      test('with errors', () async {
        final provider = generateProvider({'full_name': 'Thomas'}, errors: ['Already exists']);

        final instance = DemoModel(name: 'Thomas');
        final didDelete = await provider.delete<DemoModel>(instance);
        expect(didDelete, false);
      });
    });

    group('#exists', () {
      test('success', () async {
        final provider = generateProvider({'full_name': 'Thomas'});

        expect(await provider.exists<DemoModel>(), true);
      });

      test('with errors', () async {
        final provider = generateProvider({'full_name': 'Thomas'}, errors: ['Already exists']);

        expect(await provider.exists<DemoModel>(), false);
      });
    });

    group('#get', () {
      test('array', () async {
        final provider = generateProvider([
          {'full_name': 'Thomas'},
        ]);

        final m = await provider.get<DemoModel>();
        final testable = m.first;
        expect(testable.name, 'Thomas');
      });

      test('single map', () async {
        final provider = generateProvider({'full_name': 'Thomas'});

        final m = await provider.get<DemoModel>();
        final testable = m.first;
        expect(testable.name, 'Thomas');
      });
    });

    test('#subscribe', () async {
      final payload = [
        {'full_name': 'Guy'},
      ];
      final provider = generateProvider(payload);

      final resp = provider.subscribe<DemoModel>();

      await for (final instance in resp) {
        expect(instance.first.name, 'Guy');
      }
    });

    test('#upsert', () async {
      final payload = {'full_name': 'Guy'};
      final provider = generateProvider([payload]);

      final instance = DemoModel(name: payload['full_name']);
      final resp = await provider.upsert<DemoModel>(instance);

      expect(resp?.data, {
        'upsertPerson': [payload],
      });
      expect(resp?.errors, isNull);
    });
  });
}
