import 'package:brick_core/core.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:gql/language.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:test/test.dart';

import '__helpers__/demo_model.dart';
import '__helpers__/stub_response.dart';
import '__mocks__.dart';

GraphqlProvider generateProvider(
  dynamic response, {
  List<String>? errors,
  String? variablesNamespace,
}) {
  return GraphqlProvider(
    modelDictionary: dictionary,
    link: stubResponse({'upsertPerson': response}, errors: errors),
    variableNamespace: variablesNamespace,
  );
}

class SampleContextEntry extends ContextEntry {
  final String useEntry;

  const SampleContextEntry(this.useEntry);

  @override
  List<Object> get fieldsForEquality => [useEntry];
}

void main() {
  group('GraphqlProvider', () {
    group('#createRequest', () {
      test('simple', () {
        final provider = generateProvider({});
        final request = provider.createRequest<DemoModel>(action: QueryAction.get);
        expect(printNode(request!.operation.document), startsWith(r'''query GetDemoModels {
  getDemoModels {'''));
      });

      test('variables:', () {
        final provider = generateProvider({});
        final variables = {'name': 'Thomas'};
        final request =
            provider.createRequest<DemoModel>(action: QueryAction.upsert, variables: variables);
        expect(printNode(request!.operation.document),
            startsWith(r'''mutation UpsertDemoModels($input: DemoModelInput!) {
  upsertDemoModel(input: $input) {'''));
        expect(request.variables, variables);
      });

      test('providerArgs#variables:', () {
        final provider = generateProvider({});
        final variables = {'name': 'Thomas'};
        final request = provider.createRequest<DemoModel>(
            action: QueryAction.upsert, query: Query(providerArgs: {'variables': variables}));
        expect(request!.variables, variables);
      });

      test('use providerArgs before passed variables', () {
        final provider = generateProvider({});
        final variables = {'name': 'Thomas'};
        final providerVariables = {'name': 'Guy'};
        final request = provider.createRequest<DemoModel>(
          action: QueryAction.upsert,
          query: Query(providerArgs: {'variables': providerVariables}),
          variables: variables,
        );
        expect(request!.variables, providerVariables);
      });

      test('providerArgs#context:', () {
        final provider = generateProvider({});
        final request = provider.createRequest<DemoModel>(
          action: QueryAction.upsert,
          query: Query(providerArgs: {
            'context': {'SampleContextEntry': SampleContextEntry('myValue')}
          }),
        );
        expect(request!.context.entry<SampleContextEntry>()?.useEntry, 'myValue');
      });

      test('without variablesNamespace', () {
        final provider = generateProvider({});
        final request = provider.createRequest<DemoModel>(
          action: QueryAction.get,
          variables: {'myVar': 1234},
        );
        expect(request!.variables, {'myVar': 1234});
      });

      test('with variablesNamespace', () {
        final provider = generateProvider({}, variablesNamespace: 'vars');
        final request = provider.createRequest<DemoModel>(
          action: QueryAction.get,
          variables: {'myVar': 1234},
        );
        expect(request!.variables, {
          'vars': {'myVar': 1234}
        });
      });
    });

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
          {'full_name': 'Thomas'}
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

    group('#queryToVariables', () {
      test('simple', () {
        final provider = generateProvider({});
        final query = Query.where('lastName', 1);
        expect(provider.queryToVariables<DemoModel>(query), {'lastName': 1});
      });

      test('nonexistent field', () {
        final provider = generateProvider({});
        final query = Query.where('unknownField', 1);
        expect(provider.queryToVariables<DemoModel>(query), {});
      });

      test('different graph name than field name', () {
        final provider = generateProvider({});
        final query = Query.where('name', 1);
        expect(provider.queryToVariables<DemoModel>(query), {'fullName': 1});
      });

      test('skips associations', () {
        final provider = generateProvider({});
        final query = Query(where: [
          Where('lastName').isExactly(1),
          Where('assoc').isExactly(Where('name').isExactly(1)),
        ]);
        expect(provider.queryToVariables<DemoModel>(query), {'lastName': 1});
      });
    });

    test('#subscribe', () async {
      final payload = [
        {'full_name': 'Guy'}
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
        'upsertPerson': [payload]
      });
      expect(resp?.errors, isNull);
    });
  });
}
