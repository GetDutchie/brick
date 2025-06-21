import 'package:brick_supabase/brick_supabase.dart';

const output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SupabaseRuntime> _$SupabaseRuntimeFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return SupabaseRuntime(
    someField: data['some_field'] as int,
    unannotatedAssoc: await AssocAdapter().fromSupabase(
      data['unannotated_assoc'],
      provider: provider,
      repository: repository,
    ),
    annotatedAssoc: await AssocAdapter().fromSupabase(
      data['annotated_assoc'],
      provider: provider,
      repository: repository,
    ),
    nullableAssoc: data['assocs_id'] == null
        ? null
        : await AssocAdapter().fromSupabase(
            data['assocs_id'],
            provider: provider,
            repository: repository,
          ),
    queried: data['queried'] as bool,
    queriedMultiline: data['queried_multiline'] as bool,
  );
}

Future<Map<String, dynamic>> _$SupabaseRuntimeToSupabase(
  SupabaseRuntime instance, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return {
    'some_field': instance.someField,
    'unannotated_assoc': await AssocAdapter().toSupabase(
      instance.unannotatedAssoc,
      provider: provider,
      repository: repository,
    ),
    'annotated_assoc': await AssocAdapter().toSupabase(
      instance.annotatedAssoc,
      provider: provider,
      repository: repository,
    ),
    'assocs_id': instance.nullableAssoc != null
        ? await AssocAdapter().toSupabase(
            instance.nullableAssoc!,
            provider: provider,
            repository: repository,
          )
        : null,
    'queried': instance.queried,
    'queried_multiline': instance.queriedMultiline,
  };
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
      associationIsNullable: false,
    ),
    'annotatedAssoc': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'annotated_assoc',
      associationType: Assoc,
      associationIsNullable: false,
      foreignKey: 'assocs_id',
    ),
    'nullableAssoc': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'assocs_id',
      associationType: Assoc,
      associationIsNullable: true,
    ),
    'queried': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'queried',
      query: '''queried_custom_id''',
    ),
    'queriedMultiline': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'queried_multiline',
      query: '''queried_custom_id:table(
    id,
    name
  )''',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {};

  @override
  Future<SupabaseRuntime> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant SupabaseFirstRepository? repository,
  }) async => await _$SupabaseRuntimeFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    SupabaseRuntime input, {
    required provider,
    covariant SupabaseFirstRepository? repository,
  }) async => await _$SupabaseRuntimeToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
}
""";

@SupabaseSerializable()
class SupabaseRuntime extends SupabaseModel {
  final int someField;

  final Assoc unannotatedAssoc;

  @Supabase(foreignKey: 'assocs_id')
  final Assoc annotatedAssoc;

  @Supabase(name: 'assocs_id')
  final Assoc? nullableAssoc;

  @Supabase(query: 'queried_custom_id')
  final bool queried;

  @Supabase(
    query: '''queried_custom_id:table(
    id,
    name
  )''',
  )
  final bool queriedMultiline;

  SupabaseRuntime({
    required this.unannotatedAssoc,
    required this.annotatedAssoc,
    required this.someField,
    this.nullableAssoc,
    required this.queried,
    required this.queriedMultiline,
  });
}

class Assoc extends SupabaseModel {
  @Supabase(unique: true)
  final int someField;

  Assoc(this.someField);
}
