// ignore: unused_import
// ignore_for_file: constant_identifier_names

import 'dart:convert';

// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/query.dart';
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first/brick_offline_first.dart' show RuntimeOfflineFirstDefinition;
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/brick_sqlite.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/db.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_supabase/brick_supabase.dart';
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
)
class Customer extends OfflineFirstWithSupabaseModel {
  @Sqlite(unique: true)
  final int? id;

  final String? firstName;

  final String? lastName;

  final List<Pizza> pizzas;

  Customer({
    this.id,
    this.firstName,
    this.lastName,
    required this.pizzas,
  });

  @override
  int get hashCode => id.hashCode ^ firstName.hashCode ^ lastName.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Customer &&
      other.id == id &&
      other.firstName == firstName &&
      other.lastName == lastName;

  @override
  String toString() {
    return 'Customer(id: $id, firstName: $firstName, lastName: $lastName, pizzas: $pizzas)';
  }
}

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
)
class Pizza extends OfflineFirstWithSupabaseModel {
  /// Read more about `@Sqlite`: https://github.com/GetDutchie/brick/tree/main/packages/brick_sqlite#fields
  @Sqlite(unique: true)
  final int id;

  /// Read more about `@Supabase`: https://github.com/GetDutchie/brick/tree/main/packages/brick_supabase#fields
  @Supabase(enumAsString: true)
  final List<Topping> toppings;

  final bool frozen;

  Pizza({
    required this.id,
    required this.toppings,
    required this.frozen,
  });
}

enum Topping { olive, pepperoni }

/// Supabase mappings should only be used when initializing a [SupabaseProvider]
final Map<Type, SupabaseAdapter<SupabaseModel>> supabaseMappings = {
  Customer: CustomerAdapter(),
  Pizza: PizzaAdapter(),
};
final supabaseModelDictionary = SupabaseModelDictionary(supabaseMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Customer: CustomerAdapter(),
  Pizza: PizzaAdapter(),
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);

Future<Pizza> _$PizzaFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Pizza(
    id: data['id'] as int,
    toppings:
        data['toppings'].whereType<String>().map(Topping.values.byName).toList().cast<Topping>(),
    frozen: data['frozen'] as bool,
  );
}

Future<Map<String, dynamic>> _$PizzaToSupabase(
  Pizza instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'toppings': instance.toppings.map((e) => e.name).toList(),
    'frozen': instance.frozen,
  };
}

Future<Pizza> _$PizzaFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Pizza(
    id: data['id'] as int,
    toppings: jsonDecode(data['toppings'])
        .map((d) => d as int > -1 ? Topping.values[d] : null)
        .whereType<Topping>()
        .toList()
        .cast<Topping>(),
    frozen: data['frozen'] == 1,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$PizzaToSqlite(
  Pizza instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'toppings': jsonEncode(instance.toppings.map((s) => Topping.values.indexOf(s)).toList()),
    'frozen': instance.frozen ? 1 : 0,
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
    'toppings': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'toppings',
    ),
    'frozen': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'frozen',
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
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Pizza instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `Pizza` WHERE id = ? LIMIT 1''',
      [instance.id],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'Pizza';

  @override
  Future<Pizza> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$PizzaFromSupabase(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSupabase(
    Pizza input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$PizzaToSupabase(input, provider: provider, repository: repository);
  @override
  Future<Pizza> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$PizzaFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(
    Pizza input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$PizzaToSqlite(input, provider: provider, repository: repository);
}

Future<Customer> _$CustomerFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Customer(
    id: data['id'] as int?,
    firstName: data['first_name'] as String?,
    lastName: data['last_name'] as String?,
    pizzas: await Future.wait<Pizza>(
      data['pizzas']
              ?.map(
                (d) => PizzaAdapter().fromSupabase(d, provider: provider, repository: repository),
              )
              .toList()
              .cast<Future<Pizza>>() ??
          [],
    ),
  );
}

Future<Map<String, dynamic>> _$CustomerToSupabase(
  Customer instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'first_name': instance.firstName,
    'last_name': instance.lastName,
    'pizzas': await Future.wait<Map<String, dynamic>>(
      instance.pizzas
          .map((s) => PizzaAdapter().toSupabase(s, provider: provider, repository: repository))
          .toList(),
    ),
  };
}

Future<Customer> _$CustomerFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Customer(
    id: data['id'] == null ? null : data['id'] as int?,
    firstName: data['first_name'] == null ? null : data['first_name'] as String?,
    lastName: data['last_name'] == null ? null : data['last_name'] as String?,
    pizzas: (await provider.rawQuery(
      'SELECT DISTINCT `f_Pizza_brick_id` FROM `_brick_Customer_pizzas` WHERE l_Customer_brick_id = ?',
      [data['_brick_id'] as int],
    ).then((results) {
      final ids = results.map((r) => r['f_Pizza_brick_id']);
      return Future.wait<Pizza>(
        ids.map(
          (primaryKey) => repository!
              .getAssociation<Pizza>(
                Query.where('primaryKey', primaryKey, limit1: true),
              )
              .then((r) => r!.first),
        ),
      );
    }))
        .toList()
        .cast<Pizza>(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CustomerToSqlite(
  Customer instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
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
    ),
    'pizzas': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'pizzas',
      associationType: Pizza,
      associationIsNullable: false,
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
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Customer instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `Customer` WHERE id = ? LIMIT 1''',
      [instance.id],
    );

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
        [instance.primaryKey],
      );
      final pizzasOldIds = pizzasOldColumns.map((a) => a['f_Pizza_brick_id']);
      final pizzasNewIds = instance.pizzas.map((s) => s.primaryKey).whereType<int>();
      final pizzasIdsToDelete = pizzasOldIds.where((id) => !pizzasNewIds.contains(id));

      await Future.wait<void>(
        pizzasIdsToDelete.map((id) async {
          return await provider.rawExecute(
            'DELETE FROM `_brick_Customer_pizzas` WHERE `l_Customer_brick_id` = ? AND `f_Pizza_brick_id` = ?',
            [instance.primaryKey, id],
          ).catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.pizzas.map((s) async {
          final id = s.primaryKey ?? await provider.upsert<Pizza>(s, repository: repository);
          return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_Customer_pizzas` (`l_Customer_brick_id`, `f_Pizza_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id],
          );
        }),
      );
    }
  }

  @override
  Future<Customer> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$CustomerFromSupabase(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSupabase(
    Customer input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$CustomerToSupabase(input, provider: provider, repository: repository);
  @override
  Future<Customer> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$CustomerFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(
    Customer input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$CustomerToSqlite(input, provider: provider, repository: repository);
}

const List<MigrationCommand> _migration_20240906052847_up = [
  InsertTable('_brick_Customer_pizzas'),
  InsertTable('Customer'),
  InsertTable('Pizza'),
  InsertForeignKey(
    '_brick_Customer_pizzas',
    'Customer',
    foreignKeyColumn: 'l_Customer_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_Customer_pizzas',
    'Pizza',
    foreignKeyColumn: 'f_Pizza_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertColumn('id', Column.integer, onTable: 'Customer', unique: true),
  InsertColumn('first_name', Column.varchar, onTable: 'Customer'),
  InsertColumn('last_name', Column.varchar, onTable: 'Customer'),
  InsertColumn('id', Column.integer, onTable: 'Pizza', unique: true),
  InsertColumn('toppings', Column.varchar, onTable: 'Pizza'),
  InsertColumn('frozen', Column.boolean, onTable: 'Pizza'),
  CreateIndex(
    columns: ['l_Customer_brick_id', 'f_Pizza_brick_id'],
    onTable: '_brick_Customer_pizzas',
    unique: true,
  ),
];

const List<MigrationCommand> _migration_20240906052847_down = [
  DropTable('_brick_Customer_pizzas'),
  DropTable('Customer'),
  DropTable('Pizza'),
  DropColumn('l_Customer_brick_id', onTable: '_brick_Customer_pizzas'),
  DropColumn('f_Pizza_brick_id', onTable: '_brick_Customer_pizzas'),
  DropColumn('id', onTable: 'Customer'),
  DropColumn('first_name', onTable: 'Customer'),
  DropColumn('last_name', onTable: 'Customer'),
  DropColumn('id', onTable: 'Pizza'),
  DropColumn('toppings', onTable: 'Pizza'),
  DropColumn('frozen', onTable: 'Pizza'),
  DropIndex('index__brick_Customer_pizzas_on_l_Customer_brick_id_f_Pizza_brick_id'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20240906052847',
  up: _migration_20240906052847_up,
  down: _migration_20240906052847_down,
)
class Migration20240906052847 extends Migration {
  const Migration20240906052847()
      : super(
          version: 20240906052847,
          up: _migration_20240906052847_up,
          down: _migration_20240906052847_down,
        );
}
