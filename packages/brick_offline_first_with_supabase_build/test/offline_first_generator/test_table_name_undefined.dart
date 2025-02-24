import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<UndefinedCamelizedName> _$UndefinedCamelizedNameFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return UndefinedCamelizedName(someLongField: data['some_long_field'] as int);
}

Future<Map<String, dynamic>> _$UndefinedCamelizedNameToSupabase(
  UndefinedCamelizedName instance, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<UndefinedCamelizedName> _$UndefinedCamelizedNameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return UndefinedCamelizedName(someLongField: data['some_long_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$UndefinedCamelizedNameToSqlite(
  UndefinedCamelizedName instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

/// Construct a [UndefinedCamelizedName]
class UndefinedCamelizedNameAdapter
    extends OfflineFirstAdapter<UndefinedCamelizedName> {
  UndefinedCamelizedNameAdapter();

  @override
  final supabaseTableName = 'undefined_camelized_names';
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
    UndefinedCamelizedName instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'UndefinedCamelizedName';

  @override
  Future<UndefinedCamelizedName> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$UndefinedCamelizedNameFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    UndefinedCamelizedName input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$UndefinedCamelizedNameToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<UndefinedCamelizedName> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$UndefinedCamelizedNameFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    UndefinedCamelizedName input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$UndefinedCamelizedNameToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable.defaults,
)
class UndefinedCamelizedName extends OfflineFirstModel {
  final int someLongField;

  UndefinedCamelizedName(this.someLongField);
}
