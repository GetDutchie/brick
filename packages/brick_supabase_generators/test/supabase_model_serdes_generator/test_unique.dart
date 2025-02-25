import 'package:brick_supabase/brick_supabase.dart';

const output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SupabaseUnique> _$SupabaseUniqueFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return SupabaseUnique(someField: data['some_field'] as int);
}

Future<Map<String, dynamic>> _$SupabaseUniqueToSupabase(
  SupabaseUnique instance, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return {'some_field': instance.someField};
}

/// Construct a [SupabaseUnique]
class SupabaseUniqueAdapter extends SupabaseFirstAdapter<SupabaseUnique> {
  SupabaseUniqueAdapter();

  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'someField': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'some_field',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'someField'};

  @override
  Future<SupabaseUnique> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant SupabaseFirstRepository? repository,
  }) async => await _$SupabaseUniqueFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    SupabaseUnique input, {
    required provider,
    covariant SupabaseFirstRepository? repository,
  }) async => await _$SupabaseUniqueToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
}
""";

@SupabaseSerializable()
class SupabaseUnique extends SupabaseModel {
  @Supabase(unique: true)
  final int someField;

  SupabaseUnique(this.someField);
}
