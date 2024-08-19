import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_offline_first_with_supabase_abstract/brick_offline_first_with_supabase_abstract.dart';
import 'package:brick_offline_first_with_supabase_build/src/offline_first_with_supabase_generator.dart';
import 'package:test/test.dart';

import 'offline_first_generator/test_specify_field_name.dart' as specifyFieldName;

final _generator = OfflineFirstWithSupabaseGenerator();
final folder = 'offline_first_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('OfflineFirstWithSupabaseGenerator', () {
    group('FieldSerializable', () {
      test('name', () async {
        await generateExpectation('specify_field_name', specifyFieldName.output);
      });
    });
  });
}

Future<void> generateExpectation(
  String filename,
  String output, {
  OfflineFirstWithSupabaseGenerator? generator,
}) async {
  final reader = await generateReader(filename);
  final generated = await (generator ?? _generator).generate(reader, MockBuildStep());
  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(
  String filename,
  String output, {
  OfflineFirstWithSupabaseGenerator? generator,
}) async {
  final annotation = await annotationForFile<ConnectOfflineFirstWithSupabase>(folder, filename);
  final generated = (generator ?? _generator).generateAdapter(
    annotation.element,
    annotation.annotation,
    MockBuildStep(),
  );
  expect(generated.trim(), output.trim());
}
