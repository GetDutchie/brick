// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Customer> _$CustomerFromRest(Map<String, dynamic> data,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Customer(
      id: data['id'] as int?,
      firstName: data['first_name'] as String?,
      lastName: data['last_name'] as String?,
      pizzas: (await Future.wait<Pizza?>((data['pizza_ids'] ?? []).map<Future<Pizza?>>((s) =>
              repository!
                  .getAssociation<Pizza>(Query(where: [Where.exact('id', s)]))
                  .then((r) => r?.isNotEmpty ?? false ? r!.first : null))))
          .whereType<Pizza>()
          .toList());
}

Future<Map<String, dynamic>> _$CustomerToRest(Customer instance,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'first_name': instance.firstName,
    'last_name': instance.lastName,
    'pizza_ids': instance.pizzas?.map((s) => s.id).toList()
  };
}

Future<Customer> _$CustomerFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Customer(
      id: data['id'] == null ? null : data['id'] as int?,
      firstName: data['first_name'] == null ? null : data['first_name'] as String?,
      lastName: data['last_name'] == null ? null : data['last_name'] as String?,
      pizzas: (await provider.rawQuery(
              'SELECT DISTINCT `f_Pizza_brick_id` FROM `_brick_Customer_pizzas` WHERE l_Customer_brick_id = ?',
              [data['_brick_id'] as int]).then((results) {
        final ids = results.map((r) => r['f_Pizza_brick_id']);
        return Future.wait<Pizza>(ids.map((primaryKey) => repository!
            .getAssociation<Pizza>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toList()
          .cast<Pizza>())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CustomerToSqlite(Customer instance,
    {required SqliteProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return {'id': instance.id, 'first_name': instance.firstName, 'last_name': instance.lastName};
}

/// Construct a [Customer]
class CustomerAdapter extends OfflineFirstWithRestAdapter<Customer> {
  CustomerAdapter();

  @override
  final restRequest = CustomerRequestTransformer.new;
  @override
  final fieldsToOfflineFirstRuntimeDefinition = <String, RuntimeOfflineFirstDefinition>{
    'pizzas': const RuntimeOfflineFirstDefinition(
      where: <String, String>{'id': "data['pizza_ids']"},
    )
  };
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
      type: int,
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
    'pizzas': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'pizzas',
      iterable: true,
      type: Pizza,
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
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      final pizzasOldColumns = await provider.rawQuery(
          'SELECT `f_Pizza_brick_id` FROM `_brick_Customer_pizzas` WHERE `l_Customer_brick_id` = ?',
          [instance.primaryKey]);
      final pizzasOldIds = pizzasOldColumns.map((a) => a['f_Pizza_brick_id']);
      final pizzasNewIds = instance.pizzas?.map((s) => s.primaryKey).whereType<int>() ?? [];
      final pizzasIdsToDelete = pizzasOldIds.where((id) => !pizzasNewIds.contains(id));

      await Future.wait<void>(pizzasIdsToDelete.map((id) async {
        return await provider.rawExecute(
            'DELETE FROM `_brick_Customer_pizzas` WHERE `l_Customer_brick_id` = ? AND `f_Pizza_brick_id` = ?',
            [instance.primaryKey, id]).catchError((e) => null);
      }));

      await Future.wait<int?>(instance.pizzas?.map((s) async {
            final id = s.primaryKey ?? await provider.upsert<Pizza>(s, repository: repository);
            return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_Customer_pizzas` (`l_Customer_brick_id`, `f_Pizza_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id]);
          }) ??
          []);
    }
  }

  @override
  Future<Customer> fromRest(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$CustomerFromRest(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(Customer input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$CustomerToRest(input, provider: provider, repository: repository);
  @override
  Future<Customer> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$CustomerFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Customer input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$CustomerToSqlite(input, provider: provider, repository: repository);
}
