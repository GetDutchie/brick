// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Pizza> _$PizzaFromSupabase(Map<String, dynamic> data,
    {required SupabaseProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return Pizza(
      id: data['id'] as int,
      toppings: data['toppings'].map(Topping.values.byName).toList().cast<Topping>(),
      frozen: data['frozen'] as bool);
}

Future<Map<String, dynamic>> _$PizzaToSupabase(Pizza instance,
    {required SupabaseProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return {
    'id': instance.id,
    'toppings': instance.toppings.map((e) => e.name).toList(),
    'frozen': instance.frozen
  };
}

Future<Pizza> _$PizzaFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
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
    {required SqliteProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return {
    'id': instance.id,
    'toppings': jsonEncode(instance.toppings.map((s) => Topping.values.indexOf(s)).toList()),
    'frozen': instance.frozen ? 1 : 0
  };
}

/// Construct a [Pizza]
class PizzaAdapter extends OfflineFirstWithSupabaseAdapter<Pizza> {
  PizzaAdapter();

  @override
  final tableName = 'pizzas';
  @override
  final defaultToNull = true;
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      associationForeignKey: 'null',
      associationType: int,
      columnName: 'id',
    ),
    'toppings': const RuntimeSupabaseColumnDefinition(
      association: false,
      associationForeignKey: 'null',
      associationType: Topping,
      columnName: 'toppings',
    ),
    'frozen': const RuntimeSupabaseColumnDefinition(
      association: false,
      associationForeignKey: 'null',
      associationType: bool,
      columnName: 'frozen',
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
