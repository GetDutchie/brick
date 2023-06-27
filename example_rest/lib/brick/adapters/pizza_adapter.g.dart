// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Pizza> _$PizzaFromRest(Map<String, dynamic> data,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Pizza(
      id: data['id'] as int,
      toppings:
          data['toppings'].whereType<String>().map(Topping.values.byName).toList().cast<Topping>(),
      frozen: data['frozen'] as bool);
}

Future<Map<String, dynamic>> _$PizzaToRest(Pizza instance,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'toppings': instance.toppings.map((e) => e.name).toList(),
    'frozen': instance.frozen
  };
}

Future<Pizza> _$PizzaFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Pizza(
      id: data['id'] as int,
      toppings: jsonDecode(data['toppings'])
          .map((d) => d as int > -1 ? Topping.values[d] : null)
          .whereType<Topping>()
          .toList()
          .cast<Topping>(),
      frozen: data['frozen'] == 1)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$PizzaToSqlite(Pizza instance,
    {required SqliteProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'toppings': jsonEncode(instance.toppings.map((s) => Topping.values.indexOf(s)).toList()),
    'frozen': instance.frozen ? 1 : 0
  };
}

/// Construct a [Pizza]
class PizzaAdapter extends OfflineFirstWithRestAdapter<Pizza> {
  PizzaAdapter();

  @override
  final restRequest = PizzaRequestTransformer.new;
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
    'toppings': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'toppings',
      iterable: true,
      type: Topping,
    ),
    'frozen': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'frozen',
      iterable: false,
      type: bool,
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
  Future<Pizza> fromRest(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$PizzaFromRest(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(Pizza input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$PizzaToRest(input, provider: provider, repository: repository);
  @override
  Future<Pizza> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$PizzaFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Pizza input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$PizzaToSqlite(input, provider: provider, repository: repository);
}
