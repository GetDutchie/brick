import 'package:brick_supabase/brick_supabase.dart';

final output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SupabaseRuntime> _$SupabaseRuntimeFromSupabase(Map<String, dynamic> data,
    {required SupabaseProvider provider,
    SupabaseFirstRepository? repository}) async {
  return SupabaseRuntime(
      someField: data['some_field'] as int,
      unannotatedAssoc: await AssocAdapter().fromSupabase(
          data['unannotated_assoc'],
          provider: provider,
          repository: repository),
      annotatedAssoc: await AssocAdapter().fromSupabase(data['annotated_assoc'],
          provider: provider, repository: repository),
      differentNameAssoc: await AssocAdapter().fromSupabase(
          data['differing_name'],
          provider: provider,
          repository: repository));
}

Future<Map<String, dynamic>> _$SupabaseRuntimeToSupabase(
    SupabaseRuntime instance,
    {required SupabaseProvider provider,
    SupabaseFirstRepository? repository}) async {
  return {'some_field': instance.someField};
}

/// Construct a [SupabaseRuntime]
class SupabaseRuntimeAdapter extends SupabaseFirstAdapter<SupabaseRuntime> {
  SupabaseRuntimeAdapter();

  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'someField': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'some_field',
    ),
    'unannotatedAssoc': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'unannotated_assoc',
      associationType: Assoc,
    ),
    'annotatedAssoc': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'annotated_assoc',
      associationForeignKey: 'assoc_id',
      associationType: Assoc,
    ),
    'differentNameAssoc': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'differing_name',
      associationForeignKey: 'assoc_id',
      associationType: Assoc,
    )
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {};

  @override
  Future<SupabaseRuntime> fromSupabase(Map<String, dynamic> input,
          {required provider,
          covariant SupabaseFirstRepository? repository}) async =>
      await _$SupabaseRuntimeFromSupabase(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSupabase(SupabaseRuntime input,
          {required provider,
          covariant SupabaseFirstRepository? repository}) async =>
      await _$SupabaseRuntimeToSupabase(input,
          provider: provider, repository: repository);
}
""";

@SupabaseSerializable()
class SupabaseRuntime extends SupabaseModel {
  final int someField;

  final Assoc unannotatedAssoc;

  @Supabase(foreignKey: 'assoc_id')
  final Assoc annotatedAssoc;

  @Supabase(foreignKey: 'assoc_id', name: 'differing_name')
  final Assoc differentNameAssoc;

  SupabaseRuntime({
    required this.unannotatedAssoc,
    required this.annotatedAssoc,
    required this.someField,
    required this.differentNameAssoc,
  });
}

class Assoc extends SupabaseModel {
  @Supabase(unique: true)
  final int someField;

  Assoc(this.someField);
}
