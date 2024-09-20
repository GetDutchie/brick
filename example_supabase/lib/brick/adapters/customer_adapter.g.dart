// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Customer> _$CustomerFromSupabase(Map<String, dynamic> data,
    {required SupabaseProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return Customer(
      id: data['id'] as String,
      firstName: data['first_name'] as String?,
      lastName: data['last_name'] as String?);
}

Future<Map<String, dynamic>> _$CustomerToSupabase(Customer instance,
    {required SupabaseProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return {'id': instance.id, 'first_name': instance.firstName, 'last_name': instance.lastName};
}

Future<Customer> _$CustomerFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return Customer(
      id: data['id'] as String,
      firstName: data['first_name'] == null ? null : data['first_name'] as String?,
      lastName: data['last_name'] == null ? null : data['last_name'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CustomerToSqlite(Customer instance,
    {required SqliteProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return {'id': instance.id, 'first_name': instance.firstName, 'last_name': instance.lastName};
}

/// Construct a [Customer]
class CustomerAdapter extends OfflineFirstWithSupabaseAdapter<Customer> {
  CustomerAdapter();

  @override
  final supabaseTableName = 'customers';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'firstName': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'first_name',
    ),
    'lastName': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'last_name',
    )
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
    'id': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id',
      iterable: false,
      type: String,
    ),
    'firstName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'first_name',
      iterable: false,
      type: String,
    ),
    'lastName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_name',
      iterable: false,
      type: String,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Customer instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `Customer` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'Customer';

  @override
  Future<Customer> fromSupabase(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$CustomerFromSupabase(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSupabase(Customer input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$CustomerToSupabase(input, provider: provider, repository: repository);
  @override
  Future<Customer> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$CustomerFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Customer input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$CustomerToSqlite(input, provider: provider, repository: repository);
}
