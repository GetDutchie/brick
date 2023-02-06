import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_with_rest_generator.dart';
import 'package:test/test.dart';
import 'package:brick_build_test/brick_build_test.dart';

import 'offline_first_generator/test_rest_config_endpoint.dart' as _$restConfigEndpoint;
import 'offline_first_generator/test_rest_config_field_rename.dart' as _$restConfigFieldRename;
import 'offline_first_generator/test_custom_serdes.dart' as _$customSerdes;
import 'offline_first_generator/test_specify_field_name.dart' as _$specifyFieldName;

final _generator = OfflineFirstWithRestGenerator();
final folder = 'offline_first_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('OfflineFirstWithRestGenerator', () {
    group('#generate', () {
      test('CustomSerdes', () async {
        await generateExpectation('custom_serdes', _$customSerdes.output);
      });
    });

    group('@ConnectOfflineFirstWithRest', () {
      test('restSerializable#endpoint', () async {
        await generateAdapterExpectation('rest_config_endpoint', _$restConfigEndpoint.output);
      });

      test('restSerializable#nullable', () {}, skip: 'Write implementation and then write test');

      test('restSerializable#fieldRename', () async {
        await generateExpectation('rest_config_field_rename', _$restConfigFieldRename.output);
      });
    });

    group('FieldSerializable', () {
      test('name', () async {
        await generateExpectation('specify_field_name', _$specifyFieldName.output);
      });
    });
  });
}

Future<void> generateExpectation(String filename, String output,
    {OfflineFirstWithRestGenerator? generator}) async {
  final reader = await generateReader(filename);
  final generated = await (generator ?? _generator).generate(reader, MockBuildStep());
  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(String filename, String output,
    {OfflineFirstWithRestGenerator? generator}) async {
  final annotation = await annotationForFile<ConnectOfflineFirstWithRest>(folder, filename);
  final generated = (generator ?? _generator).generateAdapter(
    annotation.element,
    annotation.annotation,
    MockBuildStep(),
  );
  expect(generated.trim(), output.trim());
}
