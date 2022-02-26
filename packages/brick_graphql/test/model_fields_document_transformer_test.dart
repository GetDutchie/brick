import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/transformers/graphql_argument.dart';
import 'package:brick_graphql/src/transformers/graphql_variable.dart';
import 'package:brick_graphql/src/transformers/model_fields_document_transformer.dart';
import 'package:gql/ast.dart';
import 'package:gql/language.dart' as lang;
import 'package:test/test.dart';

import '__helpers__/demo_model.dart';
import '__mocks__.dart';

const upsertPersonWithoutNodesHeader = r'''mutation UpsertPerson($input: UpsertPersonInput!) {
  upsertPerson(input: $input) {}
}''';

const upsertPersonWithoutArgumentsHeader = r'''mutation UpsertPerson {
  upsertPerson {}
}''';

const upsertPersonWithNodes = r'''mutation UpsertPerson($input: UpsertPersonInput!) {
  upsertPerson(input: $input) {
    primaryKey
    id
    assoc
    someField
    complexFieldName
    lastName
    name
    simpleBool
  }
}''';

const upsertPersonWithoutArguments = r'''mutation UpsertPerson {
  upsertPerson {
    primaryKey
    id
    assoc
    someField
    complexFieldName
    lastName
    name
    simpleBool
  }
}''';

void main() {
  group('ModelFieldsDocumentTransformer', () {
    group('default constructor', () {
      test('simple', () {
        final transformer = ModelFieldsDocumentTransformer<DemoModel>(
          modelDictionary: dictionary,
          operationFunctionName: 'upsertPerson',
          operationNameNode: 'UpsertPerson',
          operationType: OperationType.mutation,
        );
        expect(
          lang.printNode(transformer.document),
          upsertPersonWithoutArguments,
        );
      });

      test('single argument', () {
        final variable = GraphqlVariable(className: 'UpsertPersonInput', name: 'input');
        final transformer = ModelFieldsDocumentTransformer<DemoModel>(
          arguments: [GraphqlArgument(name: 'input', variable: variable)],
          modelDictionary: dictionary,
          operationFunctionName: 'upsertPerson',
          operationNameNode: 'UpsertPerson',
          operationType: OperationType.mutation,
          variables: [variable],
        );

        expect(
          lang.printNode(transformer.document),
          upsertPersonWithNodes,
        );
      });

      test('association', () {
        final transformer = ModelFieldsDocumentTransformer<DemoModel>(
          modelDictionary: dictionary,
          operationFunctionName: 'upsertPerson',
          operationNameNode: 'UpsertPerson',
          operationType: OperationType.query,
        );

        expect(
          lang.printNode(transformer.document),
          r'''query UpsertPerson {
  upsertPerson {
    primaryKey
    id
    assoc {
      primaryKey
      name
    }
    someField
    complexFieldName
    lastName
    name
    simpleBool
  }
}''',
        );
      });

      test('subfields', () {
        final transformer = ModelFieldsDocumentTransformer<DemoModelAssocWithSubfields>(
          modelDictionary: dictionary,
          operationFunctionName: 'upsertPerson',
          operationNameNode: 'UpsertPerson',
          operationType: OperationType.query,
        );

        expect(
          lang.printNode(transformer.document),
          r'''query UpsertPerson {
  upsertPerson {
    primaryKey
    name {
      first
      last
    }
  }
}''',
        );
      });
    });

    group('.concat', () {
      test('without arguments', () {
        final nodes = lang.parseString(upsertPersonWithoutArgumentsHeader);
        final transformer = ModelFieldsDocumentTransformer.concat<DemoModel>(nodes, dictionary);
        final linesFromTransformer = lang.printNode(transformer.document).split('\n');
        final linesFromSource = upsertPersonWithoutArgumentsHeader.split('\n');
        expect(linesFromTransformer[0], linesFromSource[0]);
        expect(lang.printNode(transformer.document), upsertPersonWithoutArguments);
      });

      test('without nodes', () {
        final nodes = lang.parseString(upsertPersonWithoutNodesHeader);
        final transformer = ModelFieldsDocumentTransformer.concat<DemoModel>(nodes, dictionary);
        final linesFromTransformer = lang.printNode(transformer.document).split('\n');
        final linesFromSource = upsertPersonWithoutNodesHeader.split('\n');
        expect(linesFromTransformer[0], linesFromSource[0]);
        expect(lang.printNode(transformer.document), upsertPersonWithNodes);
      });

      test('with nodes', () {
        final nodes = lang.parseString(upsertPersonWithoutNodesHeader);
        final transformer = ModelFieldsDocumentTransformer.concat<DemoModel>(nodes, dictionary);
        final linesFromTransformer = lang.printNode(transformer.document).split('\n');
        final linesFromSource = upsertPersonWithoutNodesHeader.split('\n');
        expect(linesFromTransformer[0], linesFromSource[0]);
        expect(lang.printNode(transformer.document), upsertPersonWithNodes);
      });
    });

    group('.concatFromString', () {
      test('without nodes', () {
        final transformer = ModelFieldsDocumentTransformer.concatFromString<DemoModel>(
          upsertPersonWithoutNodesHeader,
          dictionary,
        );
        expect(lang.printNode(transformer.document), upsertPersonWithNodes);
      });

      test('with other nodes', () {
        final transformer = ModelFieldsDocumentTransformer.concatFromString<DemoModel>(
          r'''mutation UpsertPerson($input: UpsertPersonInput!) {
            upsertPerson(input: $input) {
              id
              horse
              hat
              car
            }
          }''',
          dictionary,
        );

        expect(lang.printNode(transformer.document), upsertPersonWithNodes);
      });
    });

    group('.defaultOperation', () {
      test('with specified document', () {
        final query = Query(providerArgs: {'document': upsertPersonWithNodes});
        final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(dictionary,
            action: QueryAction.get, query: query);
        expect(lang.printNode(transformer.document),
            startsWith(r'''mutation UpsertPerson($input: UpsertPersonInput!) {
  upsertPerson(input: $input) {'''));
      });

      test('with delete action', () {
        final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(dictionary,
            action: QueryAction.delete);
        expect(lang.printNode(transformer.document),
            startsWith(r'''mutation DeleteDemoModel($input: DemoModelInput!) {
  deleteDemoModel(input: $input) {'''));
      });

      test('with upsert action', () {
        final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(dictionary,
            action: QueryAction.upsert);
        expect(lang.printNode(transformer.document),
            startsWith(r'''mutation UpsertDemoModels($input: DemoModelInput!) {
  upsertDemoModel(input: $input) {'''));
      });

      group('QueryAction.get', () {
        test('without query', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(dictionary,
              action: QueryAction.get);
          expect(lang.printNode(transformer.document), startsWith(r'''query GetDemoModels {
  getDemoModels {'''));
        });

        test('without query.where', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(dictionary,
              action: QueryAction.get, query: Query(action: QueryAction.get));
          expect(lang.printNode(transformer.document), startsWith(r'''query GetDemoModels {
  getDemoModels {'''));
        });

        test('with query', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(dictionary,
              action: QueryAction.get, query: Query.where('name', 'Thomas'));
          expect(lang.printNode(transformer.document),
              startsWith(r'''query GetDemoModel($input: DemoModelFilterInput!) {
  getDemoModel(input: $input) {'''));
        });
      });

      group('QueryAction.subscribe', () {
        test('without query', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(dictionary,
              action: QueryAction.subscribe);
          expect(lang.printNode(transformer.document), startsWith(r'''subscription GetDemoModels {
  getDemoModels {'''));
        });

        test('without query.where', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(dictionary,
              action: QueryAction.subscribe, query: Query(action: QueryAction.get));
          expect(lang.printNode(transformer.document), startsWith(r'''subscription GetDemoModels {
  getDemoModels {'''));
        });

        test('with query', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(dictionary,
              action: QueryAction.subscribe, query: Query.where('name', 'Thomas'));
          expect(lang.printNode(transformer.document),
              startsWith(r'''subscription GetDemoModels($input: DemoModelInput!) {
  getDemoModels(input: $input) {'''));
        });
      });
    });
  });
}
