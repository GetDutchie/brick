// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Pizza> _$PizzaFromSupabase(Map<String, dynamic> data,
    {required SupabaseProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return Pizza(
      id: data['id'] as String,
      frozen: data['frozen'] as bool,
      customer: await CustomerAdapter()
          .fromSupabase(data['customer'], provider: provider, repository: repository));
}

Future<Map<String, dynamic>> _$PizzaToSupabase(Pizza instance,
    {required SupabaseProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return {
    'id': instance.id,
    'frozen': instance.frozen,
    'customer': await CustomerAdapter()
        .toSupabase(instance.customer, provider: provider, repository: repository),
    'customer_id': instance.customerId
  };
}

Future<Pizza> _$PizzaFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return Pizza(
      id: data['id'] as String,
      frozen: data['frozen'] == 1,
      customer: (await repository!.getAssociation<Customer>(
        Query.where('primaryKey', data['customer_Customer_brick_id'] as int, limit1: true),
      ))!
          .first)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$PizzaToSqlite(Pizza instance,
    {required SqliteProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return {
    'id': instance.id,
    'frozen': instance.frozen ? 1 : 0,
    'customer_Customer_brick_id': instance.customer.primaryKey ??
        await provider.upsert<Customer>(instance.customer, repository: repository)
  };
}

/// Construct a [Pizza]
class PizzaAdapter extends OfflineFirstWithSupabaseAdapter<Pizza> {
  PizzaAdapter();

  @override
  final supabaseTableName = 'pizzas';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'frozen': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'frozen',
    ),
    'customer': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'customer',
      associationType: Customer,
      associationIsNullable: false,
      foreignKey: 'customer_id',
    ),
    'customerId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'customer_id',
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
    'frozen': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'frozen',
      iterable: false,
      type: bool,
    ),
    'customer': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'customer_Customer_brick_id',
      iterable: false,
      type: Customer,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Pizza instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `Pizza` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'Pizza';

  @override
  Future<Pizza> fromSupabase(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$PizzaFromSupabase(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSupabase(Pizza input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$PizzaToSupabase(input, provider: provider, repository: repository);
  @override
  Future<Pizza> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$PizzaFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Pizza input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$PizzaToSqlite(input, provider: provider, repository: repository);
}
