// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Customer> _$CustomerFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return Customer(
      id: data['id'] as String,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      createdAt: DateTime.parse(data['created_at'] as String));
}

Future<Map<String, dynamic>> _$CustomerToRest(Customer instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'first_name': instance.firstName,
    'last_name': instance.lastName,
    'created_at': instance.createdAt.toIso8601String()
  };
}

Future<Customer> _$CustomerFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return Customer(
      id: data['id'] as String,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      createdAt: DateTime.parse(data['created_at'] as String))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CustomerToSqlite(Customer instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'first_name': instance.firstName,
    'last_name': instance.lastName,
    'created_at': instance.createdAt.toIso8601String()
  };
}

/// Construct a [Customer]
class CustomerAdapter extends OfflineFirstWithRestAdapter<Customer> {
  CustomerAdapter();

  @override
  final restRequest = CustomerRequestTransformer.new;
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
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: DateTime,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
      Customer instance, DatabaseExecutor executor) async {
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
  Future<Customer> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$CustomerFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(Customer input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$CustomerToRest(input, provider: provider, repository: repository);
  @override
  Future<Customer> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$CustomerFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Customer input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$CustomerToSqlite(input,
          provider: provider, repository: repository);
}
