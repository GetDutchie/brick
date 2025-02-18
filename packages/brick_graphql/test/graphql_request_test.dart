import 'package:brick_core/core.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql/src/graphql_request.dart';
import 'package:gql/language.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:test/test.dart';

import '__helpers__/demo_model.dart';
import '__helpers__/stub_response.dart';
import '__mocks__.dart';

GraphqlProvider generateProvider(
  dynamic response, {
  List<String>? errors,
}) =>
    GraphqlProvider(
      modelDictionary: dictionary,
      link: stubResponse({'upsertPerson': response}, errors: errors),
    );

class SampleContextEntry extends ContextEntry {
  final String useEntry;

  const SampleContextEntry(this.useEntry);

  @override
  List<Object> get fieldsForEquality => [useEntry];
}

void main() {
  group('GraphqlRequest', () {
    final provider = generateProvider({});

    group('#request', () {
      test('simple', () {
        final request = GraphqlRequest<DemoModel>(
          action: QueryAction.get,
          modelDictionary: provider.modelDictionary,
        ).request;
        expect(
          printNode(request!.operation.document),
          startsWith('''query GetDemoModels {
  getDemoModels {'''),
        );
      });

      test('GraphqlProviderQuery#context:', () {
        final request = GraphqlRequest<DemoModel>(
          action: QueryAction.upsert,
          modelDictionary: provider.modelDictionary,
          query: Query(
            forProviders: [
              GraphqlProviderQuery(
                context: const Context().withEntry(const SampleContextEntry('myValue')),
              ),
            ],
          ),
        ).request;
        expect(request!.context.entry<SampleContextEntry>()?.useEntry, 'myValue');
      });
    });

    group('#requestVariables', () {
      test('variables:', () {
        final variables = {'name': 'Thomas'};
        final request = GraphqlRequest<DemoModel>(
          action: QueryAction.upsert,
          modelDictionary: provider.modelDictionary,
          variables: variables,
        );
        expect(
          printNode(request.request!.operation.document),
          startsWith(r'''mutation UpsertDemoModels($input: DemoModelInput!) {
  upsertDemoModel(input: $input) {'''),
        );
        expect(request.requestVariables, variables);
      });

      test('GraphqlProviderQuery#operation:', () {
        final variables = {'name': 'Thomas'};
        final request = GraphqlRequest<DemoModel>(
          action: QueryAction.upsert,
          modelDictionary: provider.modelDictionary,
          query: Query(
            forProviders: [
              GraphqlProviderQuery(
                operation: GraphqlOperation(variables: variables),
              ),
            ],
          ),
        );
        expect(request.requestVariables, variables);
      });

      test('use providerArgs before passed variables', () {
        final variables = {'name': 'Thomas'};
        final providerVariables = {'name': 'Guy'};

        final request = GraphqlRequest<DemoModel>(
          action: QueryAction.upsert,
          modelDictionary: provider.modelDictionary,
          query: Query(
            forProviders: [
              GraphqlProviderQuery(operation: GraphqlOperation(variables: providerVariables)),
            ],
          ),
          variables: variables,
        );
        expect(request.requestVariables, providerVariables);
      });

      test('without variablesNamespace', () {
        final request = GraphqlRequest<DemoModel>(
          action: QueryAction.upsert,
          modelDictionary: provider.modelDictionary,
          variables: {'myVar': 1234},
        );
        expect(request.requestVariables, {'myVar': 1234});
      });

      test('with variablesNamespace', () {
        final request = GraphqlRequest<DemoModel>(
          action: QueryAction.upsert,
          modelDictionary: provider.modelDictionary,
          variableNamespace: 'vars',
          variables: {'myVar': 1234},
        );
        expect(request.requestVariables, {
          'vars': {'myVar': 1234},
        });
      });
    });

    group('#queryToVariables', () {
      final request = GraphqlRequest<DemoModel>(
        action: QueryAction.upsert,
        modelDictionary: provider.modelDictionary,
        variableNamespace: 'vars',
        variables: {'myVar': 1234},
      );
      test('simple', () {
        final query = Query.where('lastName', 1);
        expect(request.queryToVariables(query), {'lastName': 1});
      });

      test('nonexistent field', () {
        final query = Query.where('unknownField', 1);
        expect(request.queryToVariables(query), {});
      });

      test('different graph name than field name', () {
        final query = Query.where('name', 1);
        expect(request.queryToVariables(query), {'fullName': 1});
      });

      test('skips associations', () {
        final query = Query(
          where: [
            const Where('lastName').isExactly(1),
            const Where('assoc').isExactly(const Where('name').isExactly(1)),
          ],
        );
        expect(request.queryToVariables(query), {'lastName': 1});
      });
    });
  });
}
