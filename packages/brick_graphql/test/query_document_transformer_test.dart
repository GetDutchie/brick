import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:brick_graphql/src/query_document_transformer.dart';
import 'package:test/test.dart';

import '__helpers__/demo_model.dart';
import '__mocks__.dart';

enum _MockEnum { a, b, c, d }

void main() {
  group('QueryDocumentTransformer', () {
    test('simple', () {
      final transformer = QueryDocumentTransformer<DemoModel>(
        null,
        modelDictionary: dictionary,
        operationFunctionName: 'upsertPerson',
        operationNameNode: 'UpsertPerson',
      );
      print(transformer.document);
    });
  });
}
