// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Customer> _$CustomerFromGraphql(Map<String, dynamic> data,
    {required GraphqlProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
  return Customer(
      id: data['id'] as int?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      pizzas: await Future.wait<Pizza>(data['pizzas']
              ?.map(
                  (d) => PizzaAdapter().fromGraphql(d, provider: provider, repository: repository))
              .toList()
              .cast<Future<Pizza>>() ??
          []));
}

Future<Map<String, dynamic>> _$CustomerToGraphql(Customer instance,
    {required GraphqlProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
  return {
    'id': instance.id,
    'firstName': instance.firstName,
    'lastName': instance.lastName,
    'pizzas': await Future.wait<Map<String, dynamic>>(instance.pizzas
            ?.map((s) => PizzaAdapter().toGraphql(s, provider: provider, repository: repository))
            .toList() ??
        [])
  };
}

Future<Customer> _$CustomerFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
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
    {required SqliteProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
  return {'id': instance.id, 'first_name': instance.firstName, 'last_name': instance.lastName};
}

/// Construct a [Customer]
class CustomerAdapter extends OfflineFirstWithGraphqlAdapter<Customer> {
  CustomerAdapter();

  @override
  final queryOperationTransformer = CustomerOperationTransformer.new;
  @override
  final fieldsToGraphqlRuntimeDefinition = <String, RuntimeGraphqlDefinition>{
    'id': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'id',
      iterable: false,
      subfields: <String, Map<String, dynamic>>{},
      type: int,
    ),
    'firstName': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'firstName',
      iterable: false,
      subfields: <String, Map<String, dynamic>>{},
      type: String,
    ),
    'lastName': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'lastName',
      iterable: false,
      subfields: <String, Map<String, dynamic>>{},
      type: String,
    ),
    'pizzas': const RuntimeGraphqlDefinition(
      association: true,
      documentNodeName: 'pizzas',
      iterable: true,
      subfields: <String, Map<String, dynamic>>{},
      type: Pizza,
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
  Future<Customer> fromGraphql(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$CustomerFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(Customer input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$CustomerToGraphql(input, provider: provider, repository: repository);
  @override
  Future<Customer> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$CustomerFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Customer input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$CustomerToSqlite(input, provider: provider, repository: repository);
}
