import 'package:brick_graphql/src/transformers/model_fields_document_transformer.dart';
import 'package:brick_graphql/src/transformers/graphql_variable.dart';
import 'package:brick_graphql/src/transformers/graphql_argument.dart';
import 'package:gql/ast.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:test/test.dart';
import 'package:gql/language.dart' as lang;

import '__helpers__/demo_model.dart';
import '__mocks__.dart';

const upsertPersonWithoutNodesHeader = r'''mutation UpsertPerson($input: UpsertPersonInput!) {
  upsertPerson(filter: $input) {}
}''';

const upsertPersonWithoutArgumentsHeader = r'''mutation UpsertPerson {
  upsertPerson {}
}''';

const upsertPersonWithNodes = r'''mutation UpsertPerson($input: UpsertPersonInput!) {
  upsertPerson(filter: $input) {
    primaryKey
    id
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
          arguments: [GraphqlArgument(name: 'filter', variable: variable)],
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
            upsertPerson(filter: $input) {
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

    group('.defaultOperation', () {}, skip: true);
  });
}
