import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SupabaseDefined> _$SupabaseDefinedFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseDefined(someLongField: data['some_long_field'] as int);
}

Future<Map<String, dynamic>> _$SupabaseDefinedToSupabase(
  SupabaseDefined instance, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<SupabaseDefined> _$SupabaseDefinedFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseDefined(someLongField: data['some_long_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SupabaseDefinedToSqlite(
  SupabaseDefined instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

/// Construct a [SupabaseDefined]
class SupabaseDefinedAdapter extends OfflineFirstAdapter<SupabaseDefined> {
  SupabaseDefinedAdapter();

  @override
  final supabaseTableName = 'supabase_defineds';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'someLongField': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'some_long_field',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final onConflict = 'user_id,other_id';
  @override
  final uniqueFields = {};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'someLongField': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'some_long_field',
      iterable: false,
      type: int,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    SupabaseDefined instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'SupabaseDefined';

  @override
  Future<SupabaseDefined> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$SupabaseDefinedFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    SupabaseDefined input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$SupabaseDefinedToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<SupabaseDefined> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$SupabaseDefinedFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SupabaseDefined input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$SupabaseDefinedToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(onConflict: 'user_id,other_id'),
)
class SupabaseDefined extends OfflineFirstModel {
  final int someLongField;

  SupabaseDefined(this.someLongField);
}
