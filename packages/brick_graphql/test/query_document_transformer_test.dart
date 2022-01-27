import 'package:brick_graphql/src/transformers/graphql_argument.dart';
import 'package:brick_graphql/src/transformers/graphql_variable.dart';
import 'package:brick_graphql/src/transformers/model_fields_document_transformer.dart';
import 'package:test/test.dart';
import 'package:gql/language.dart' as lang;

import '__helpers__/demo_model.dart';
import '__mocks__.dart';

void main() {
  group('QueryDocumentTransformer', () {
    test('simple', () {
      final transformer = ModelFieldsDocumentTransformer<DemoModel>(
        modelDictionary: dictionary,
        operationFunctionName: 'upsertPerson',
        operationNameNode: 'UpsertPerson',
      );
      expect(
        lang.printNode(transformer.document),
        '''query UpsertPerson {
  upsertPerson {
    primaryKey
    id
    someField
    complexFieldName
    lastName
    name
    simpleBool
  }
}''',
      );
    });

    test('single argument', () {
      final variable = GraphqlVariable(className: 'UpsertPersonInput', name: 'input');
      final transformer = ModelFieldsDocumentTransformer<DemoModel>(
        modelDictionary: dictionary,
        operationFunctionName: 'upsertPerson',
        operationNameNode: 'UpsertPerson',
        variables: [variable],
        arguments: [GraphqlArgument(name: 'filter', variable: variable)],
      );

      expect(
        lang.printNode(transformer.document),
        r'''query UpsertPerson($input: UpsertPersonInput!) {
  upsertPerson(filter: $input) {
    primaryKey
    id
    someField
    complexFieldName
    lastName
    name
    simpleBool
  }
}''',
      );
    });
  });
}
