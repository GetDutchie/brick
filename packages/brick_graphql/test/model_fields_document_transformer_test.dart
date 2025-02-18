import 'package:brick_core/core.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql/src/transformers/model_fields_document_transformer.dart';
import 'package:gql/language.dart' as lang;
import 'package:test/test.dart';

import '__helpers__/demo_model.dart';
import '__mocks__.dart';

const upsertPersonWithoutNodesHeader = r'''mutation UpsertPerson($input: UpsertPersonInput!) {
  upsertPerson(input: $input) {}
}''';

const upsertPersonWithoutArgumentsHeader = '''mutation UpsertPerson {
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
    fullName
    simpleBool
  }
}''';

const upsertPersonWithoutArguments = '''mutation UpsertPerson {
  upsertPerson {
    primaryKey
    id
    assoc
    someField
    complexFieldName
    lastName
    fullName
    simpleBool
  }
}''';

const subfields = '''query GetDemoAssocModels {
  getDemoAssocModels {
    _brick_id
    full_name {
      first {
        subfield1
      }
      last
    }
  }
}''';

void main() {
  group('ModelFieldsDocumentTransformer', () {
    test('#hasSubfields', () {
      final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
        dictionary,
        action: QueryAction.subscribe,
      );
      expect(transformer?.hasSubfields, isFalse);
    });

    test('#operationName', () {
      final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
        dictionary,
        action: QueryAction.subscribe,
      );
      expect(transformer?.operationName, 'getDemoModels');
    });

    group('.fromDocument', () {
      test('without arguments', () {
        final nodes = lang.parseString(upsertPersonWithoutArgumentsHeader);
        final transformer =
            ModelFieldsDocumentTransformer.fromDocument<DemoModel>(nodes, dictionary);
        final linesFromTransformer = lang.printNode(transformer.document).split('\n');
        final linesFromSource = upsertPersonWithoutArgumentsHeader.split('\n');
        expect(linesFromTransformer[0], linesFromSource[0]);
        expect(lang.printNode(transformer.document), upsertPersonWithoutArguments);
      });

      test('without nodes', () {
        final nodes = lang.parseString(upsertPersonWithoutNodesHeader);
        final transformer =
            ModelFieldsDocumentTransformer.fromDocument<DemoModel>(nodes, dictionary);
        final linesFromTransformer = lang.printNode(transformer.document).split('\n');
        final linesFromSource = upsertPersonWithoutNodesHeader.split('\n');
        expect(linesFromTransformer[0], linesFromSource[0]);
        expect(lang.printNode(transformer.document), upsertPersonWithNodes);
      });

      test('with nodes', () {
        final nodes = lang.parseString(upsertPersonWithoutNodesHeader);
        final transformer =
            ModelFieldsDocumentTransformer.fromDocument<DemoModel>(nodes, dictionary);
        final linesFromTransformer = lang.printNode(transformer.document).split('\n');
        final linesFromSource = upsertPersonWithoutNodesHeader.split('\n');
        expect(linesFromTransformer[0], linesFromSource[0]);
        expect(lang.printNode(transformer.document), upsertPersonWithNodes);
      });
    });

    group('.fromString', () {
      test('without nodes', () {
        final transformer = ModelFieldsDocumentTransformer.fromString<DemoModel>(
          upsertPersonWithoutNodesHeader,
          dictionary,
        );
        expect(lang.printNode(transformer.document), upsertPersonWithNodes);
      });

      test('with other nodes', () {
        const document = r'''
mutation UpsertPerson($input: UpsertPersonInput!) {
  upsertPerson(input: $input) {
    id
    horse
    hat
    car
  }
}''';
        final transformer = ModelFieldsDocumentTransformer.fromString<DemoModel>(
          document,
          dictionary,
        );

        expect(lang.printNode(transformer.document), document);
      });
    });

    group('.defaultOperation', () {
      test('with specified document', () {
        const query = Query(
          forProviders: [
            GraphqlProviderQuery(
              operation: GraphqlOperation(document: upsertPersonWithNodes),
            ),
          ],
        );
        final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
          dictionary,
          action: QueryAction.get,
          query: query,
        );
        expect(
          lang.printNode(transformer!.document),
          startsWith(r'''mutation UpsertPerson($input: UpsertPersonInput!) {
  upsertPerson(input: $input) {'''),
        );
      });

      test('with delete action', () {
        final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
          dictionary,
          action: QueryAction.delete,
        );
        expect(
          lang.printNode(transformer!.document),
          startsWith(r'''mutation DeleteDemoModel($input: DemoModelInput!) {
  deleteDemoModel(input: $input) {'''),
        );
      });

      test('with upsert action', () {
        final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
          dictionary,
          action: QueryAction.upsert,
        );
        expect(
          lang.printNode(transformer!.document),
          startsWith(r'''mutation UpsertDemoModels($input: DemoModelInput!) {
  upsertDemoModel(input: $input) {'''),
        );
      });

      test('with nested subfields', () {
        final transformer =
            ModelFieldsDocumentTransformer.defaultOperation<DemoModelAssocWithSubfields>(
          dictionary,
          action: QueryAction.get,
        );
        expect(lang.printNode(transformer!.document), subfields);
      });

      group('QueryAction.get', () {
        test('without query', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
            dictionary,
            action: QueryAction.get,
          );
          expect(
            lang.printNode(transformer!.document),
            startsWith('''query GetDemoModels {
  getDemoModels {'''),
          );
        });

        test('without query.where', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
            dictionary,
            action: QueryAction.get,
            query: const Query(action: QueryAction.get),
          );
          expect(
            lang.printNode(transformer!.document),
            startsWith('''query GetDemoModels {
  getDemoModels {'''),
          );
        });

        test('with query', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
            dictionary,
            action: QueryAction.get,
            query: Query.where('name', 'Thomas'),
          );
          expect(
            lang.printNode(transformer!.document),
            startsWith(r'''query GetDemoModel($input: DemoModelFilterInput!) {
  getDemoModel(input: $input) {'''),
          );
        });
      });

      group('QueryAction.subscribe', () {
        test('without query', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
            dictionary,
            action: QueryAction.subscribe,
          );
          expect(
            lang.printNode(transformer!.document),
            startsWith('''subscription GetDemoModels {
  getDemoModels {'''),
          );
        });

        test('without query.where', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
            dictionary,
            action: QueryAction.subscribe,
            query: const Query(action: QueryAction.get),
          );
          expect(
            lang.printNode(transformer!.document),
            startsWith('''subscription GetDemoModels {
  getDemoModels {'''),
          );
        });

        test('with query', () {
          final transformer = ModelFieldsDocumentTransformer.defaultOperation<DemoModel>(
            dictionary,
            action: QueryAction.subscribe,
            query: Query.where('name', 'Thomas'),
          );
          expect(
            lang.printNode(transformer!.document),
            startsWith(r'''subscription GetDemoModels($input: DemoModelInput!) {
  getDemoModels(input: $input) {'''),
          );
        });
      });
    });
  });
}
