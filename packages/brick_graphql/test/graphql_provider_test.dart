import 'package:brick_core/core.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:test/test.dart';

import '__helpers__/demo_model.dart';
import '__helpers__/stub_response.dart';
import '__mocks__.dart';

GraphqlProvider generateProvider(Map<String, dynamic> response, {List<String>? errors}) {
  return GraphqlProvider(
    modelDictionary: dictionary,
    link: stubResponse({
      'upsertPerson': [response]
    }, errors: errors),
  );
}

void main() {
  group('GraphqlProvider', () {
    group('#createRequest', () {}, skip: true);

    group('#get', () {
      test('simple', () async {
        final provider = generateProvider({'full_name': 'Thomas'});

        final m = await provider.get<DemoModel>();
        final testable = m.first;
        expect(testable.name, 'Thomas');
      });
    });

    test('#upsert', () async {
      final provider = generateProvider({'full_name': 'Guy'});

      final instance = DemoModel(name: 'Guy');
      final resp = await provider.upsert<DemoModel>(instance);

      expect(resp.name, instance.name);
    }, skip: true);

    group('#delete', () {
      test('success', () async {
        final provider = generateProvider({'full_name': 'Thomas'});

        final instance = DemoModel(name: 'Guy');
        final didDelete = await provider.delete<DemoModel>(instance);
        expect(didDelete, true);
      });

      test('with errors', () async {
        final provider = generateProvider({'full_name': 'Thomas'}, errors: ['Already exists']);

        final instance = DemoModel(name: 'Guy');
        final didDelete = await provider.delete<DemoModel>(instance);
        expect(didDelete, false);
      });
    });

    group('#queryToVariables', () {
      test('simple', () {
        final provider = generateProvider({});
        final query = Query.where('lastName', 1);
        expect(provider.queryToVariables<DemoModel>(query), {'last_name': 1});
      });

      test('nonexistent field', () {
        final provider = generateProvider({});
        final query = Query.where('unknownField', 1);
        expect(provider.queryToVariables<DemoModel>(query), {});
      });

      test('different graph name than field name', () {
        final provider = generateProvider({});
        final query = Query.where('name', 1);
        expect(provider.queryToVariables<DemoModel>(query), {'full_name': 1});
      });

      test('skips associations', () {
        final provider = generateProvider({});
        final query = Query(where: [
          Where('lastName').isExactly(1),
          Where('assoc').isExactly(Where('name').isExactly(1)),
        ]);
        expect(provider.queryToVariables<DemoModel>(query), {'last_name': 1});
      });
    });
  });
}
