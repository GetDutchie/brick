import 'package:brick_offline_first_with_graphql_abstract/annotations.dart';
import 'package:brick_offline_first_with_graphql_build/src/offline_first_with_graphql_generator.dart';
import 'package:test/test.dart';
import 'package:brick_build_test/brick_build_test.dart';

import 'offline_first_generator/test_graphql_config_mutation_document.dart'
    as _$graphqlMutationDocument;
import 'offline_first_generator/test_graphql_config_field_rename.dart'
    as _$graphqlConfigFieldRename;
import 'offline_first_generator/test_custom_serdes.dart' as _$customSerdes;
import 'offline_first_generator/test_specify_field_name.dart' as _$specifyFieldName;
import 'offline_first_generator/test_offline_first_where_rename.dart' as _$offlineFirstWhereRename;

final _generator = OfflineFirstWithGraphqlGenerator();
final folder = 'offline_first_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('OfflineFirstWithGraphqlGenerator', () {
    group('#generate', () {
      test('CustomSerdes', () async {
        await generateExpectation('custom_serdes', _$customSerdes.output);
      });
    });

    group('@ConnectOfflineFirstWithGraphql', () {
      test('graphqlSerializable#mutationDocument', () async {
        await generateAdapterExpectation(
            'graphql_config_mutation_document', _$graphqlMutationDocument.output);
      });

      test('graphqlSerializable#fieldRename', () async {
        await generateExpectation('graphql_config_field_rename', _$graphqlConfigFieldRename.output);
      });
    });

    group('FieldSerializable', () {
      test('name', () async {
        await generateExpectation('specify_field_name', _$specifyFieldName.output);
      });
    });

    group('OfflineFirst(where:)', () {
      test('renames the definition', () async {
        await generateAdapterExpectation(
            'offline_first_where_rename', _$offlineFirstWhereRename.output);
      });
    });
  });
}

Future<void> generateExpectation(String filename, String output,
    {OfflineFirstWithGraphqlGenerator? generator}) async {
  final reader = await generateReader(filename);
  final generated = await (generator ?? _generator).generate(reader, MockBuildStep());
  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(String filename, String output,
    {OfflineFirstWithGraphqlGenerator? generator}) async {
  final annotation = await annotationForFile<ConnectOfflineFirstWithGraphql>(folder, filename);
  final generated = (generator ?? _generator).generateAdapter(
    annotation.element,
    annotation.annotation,
    MockBuildStep(),
  );
  expect(generated.trim(), output.trim());
}
