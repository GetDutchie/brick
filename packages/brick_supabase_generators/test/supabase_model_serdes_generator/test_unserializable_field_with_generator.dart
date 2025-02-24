import 'dart:io';
import 'dart:typed_data';

import 'package:brick_supabase/brick_supabase.dart';

const output = r'''
Future<SupabaseUnserializableFieldWithGenerator>
_$SupabaseUnserializableFieldWithGeneratorFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return SupabaseUnserializableFieldWithGenerator(withFrom: data['with_from']);
}

Future<Map<String, dynamic>>
_$SupabaseUnserializableFieldWithGeneratorToSupabase(
  SupabaseUnserializableFieldWithGenerator instance, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return {'with_to': instance.withTo};
}
''';

/// Output serializing code for all models with the @[SupabaseSerializable] annotation.
/// [SupabaseSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SupabaseSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SupabaseSerializable(tableName: '')
class SupabaseUnserializableFieldWithGenerator extends SupabaseModel {
  @Supabase(fromGenerator: '%DATA_PROPERTY%')
  final File withFrom;

  @Supabase(toGenerator: '%INSTANCE_PROPERTY%')
  final Uint8List withTo;

  SupabaseUnserializableFieldWithGenerator(
    this.withFrom,
    this.withTo,
  );
}
