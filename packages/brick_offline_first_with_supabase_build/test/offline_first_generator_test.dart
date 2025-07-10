import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_offline_first_with_supabase_build/src/offline_first_with_supabase_generator.dart';
import 'package:test/test.dart';

import 'offline_first_generator/test_default_to_null.dart' as default_to_null;
import 'offline_first_generator/test_field_name.dart' as specify_field_name;
import 'offline_first_generator/test_field_rename.dart' as field_rename;
import 'offline_first_generator/test_ignore_duplicates.dart' as ignore_duplicates;
import 'offline_first_generator/test_offline_first_where.dart' as offline_first_where;
import 'offline_first_generator/test_on_conflict.dart' as on_conflict;
import 'offline_first_generator/test_table_name_defined.dart' as table_name_defined;
import 'offline_first_generator/test_table_name_undefined.dart' as table_name_undefined;

const _generator = OfflineFirstWithSupabaseGenerator();
const folder = 'offline_first_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('OfflineFirstWithSupabaseGenerator', () {
    group('FieldSerializable', () {
      test('name', () async {
        await generateExpectation('field_name', specify_field_name.output);
      });
    });

    group('@SupabaseSerializable', () {
      test('defaultToNull', () async {
        await generateAdapterExpectation('default_to_null', default_to_null.output);
      });

      test('fieldRename', () async {
        await generateExpectation('field_rename', field_rename.output);
      });

      test('ignoreDuplicates', () async {
        await generateAdapterExpectation('ignore_duplicates', ignore_duplicates.output);
      });

      test('onConflict', () async {
        await generateAdapterExpectation('on_conflict', on_conflict.output);
      });

      group('tableName', () {
        test('defined', () async {
          await generateAdapterExpectation('table_name_defined', table_name_defined.output);
        });

        test('undefined', () async {
          await generateAdapterExpectation('table_name_undefined', table_name_undefined.output);
        });
      });
    });

    group('@OfflineFirst', () {
      test('where', () async {
        await generateAdapterExpectation('offline_first_where', offline_first_where.output);
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

  if (generated.trim() != output.trim()) {
    // ignore: avoid_print
    print(generated);
  }

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

  if (generated.trim() != output.trim()) {
    // ignore: avoid_print
    print(generated);
  }

  expect(generated.trim(), output.trim());
}
