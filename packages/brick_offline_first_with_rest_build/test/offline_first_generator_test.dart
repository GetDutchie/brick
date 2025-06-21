import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_with_rest_generator.dart';
import 'package:test/test.dart';

import 'offline_first_generator/test_custom_serdes.dart' as custom_serdes;
import 'offline_first_generator/test_rest_config_endpoint.dart' as rest_config_endpoint;
import 'offline_first_generator/test_rest_config_field_rename.dart' as rest_config_field_rename;
import 'offline_first_generator/test_specify_field_name.dart' as specify_field_name;

const _generator = OfflineFirstWithRestGenerator();
const folder = 'offline_first_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('OfflineFirstWithRestGenerator', () {
    group('#generate', () {
      test('CustomSerdes', () async {
        await generateExpectation('custom_serdes', custom_serdes.output);
      });
    });

    group('@ConnectOfflineFirstWithRest', () {
      test('restSerializable#endpoint', () async {
        await generateAdapterExpectation('rest_config_endpoint', rest_config_endpoint.output);
      });

      test('restSerializable#fieldRename', () async {
        await generateExpectation('rest_config_field_rename', rest_config_field_rename.output);
      });
    });

    group('FieldSerializable', () {
      test('name', () async {
        await generateExpectation('specify_field_name', specify_field_name.output);
      });
    });
  });
}

Future<void> generateExpectation(
  String filename,
  String output, {
  OfflineFirstWithRestGenerator? generator,
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
  OfflineFirstWithRestGenerator? generator,
}) async {
  final annotation = await annotationForFile<ConnectOfflineFirstWithRest>(folder, filename);
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
