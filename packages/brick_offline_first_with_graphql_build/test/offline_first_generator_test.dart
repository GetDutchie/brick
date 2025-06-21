import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:brick_offline_first_with_graphql_build/src/offline_first_with_graphql_generator.dart';
import 'package:test/test.dart';

import 'offline_first_generator/test_custom_serdes.dart' as custom_serdes;
import 'offline_first_generator/test_graphql_config_field_rename.dart'
    as graphql_config_field_rename;
import 'offline_first_generator/test_graphql_config_query_operation_transformer.dart'
    as graphql_config_query_operation_transformer;
import 'offline_first_generator/test_offline_first_where_rename.dart' as offline_first_where_rename;
import 'offline_first_generator/test_specify_field_name.dart' as specify_field_name;

const _generator = OfflineFirstWithGraphqlGenerator();
const folder = 'offline_first_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('OfflineFirstWithGraphqlGenerator', () {
    group('#generate', () {
      test('CustomSerdes', () async {
        await generateExpectation('custom_serdes', custom_serdes.output);
      });
    });

    group('@ConnectOfflineFirstWithGraphql', () {
      test('graphqlSerializable#fieldRename', () async {
        await generateExpectation(
          'graphql_config_field_rename',
          graphql_config_field_rename.output,
        );
      });

      test('graphqlSerializable#queryOperationTransformer', () async {
        await generateAdapterExpectation(
          'graphql_config_query_operation_transformer',
          graphql_config_query_operation_transformer.output,
        );
      });
    });

    group('FieldSerializable', () {
      test('name', () async {
        await generateExpectation('specify_field_name', specify_field_name.output);
      });
    });

    group('OfflineFirst(where:)', () {
      test('renames the definition', () async {
        await generateAdapterExpectation(
          'offline_first_where_rename',
          offline_first_where_rename.output,
        );
      });
    });
  });
}

Future<void> generateExpectation(
  String filename,
  String output, {
  OfflineFirstWithGraphqlGenerator? generator,
}) async {
  final reader = await generateReader(filename);
  final generated = await (generator ?? _generator).generate(reader, MockBuildStep());

  if (generated.trim() != output.trim()) {
    // ignore: avoid_print
    print(generated);
  }

  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(
  String filename,
  String output, {
  OfflineFirstWithGraphqlGenerator? generator,
}) async {
  final annotation = await annotationForFile<ConnectOfflineFirstWithGraphql>(folder, filename);
  final generated = (generator ?? _generator).generateAdapter(
    annotation.element,
    annotation.annotation,
    MockBuildStep(),
  );

  if (generated.trim() != output.trim()) {
    // ignore: avoid_print
    print(generated);
  }

  expect(generated.trim(), output.trim());
}
