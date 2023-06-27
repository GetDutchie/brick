// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/query.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/db.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_rest/brick_rest.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/brick_sqlite.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:pizza_shoppe/brick/models/customer.model.request.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:pizza_shoppe/brick/models/pizza.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:pizza_shoppe/brick/models/pizza.model.request.dart'; // GENERATED CODE DO NOT EDIT
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/brick_sqlite.dart'
    show
        SqliteModel,
        SqliteAdapter,
        SqliteModelDictionary,
        RuntimeSqliteColumnDefinition,
        SqliteProvider;
import 'package:brick_rest/brick_rest.dart'
    show RestProvider, RestModel, RestAdapter, RestModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first/brick_offline_first.dart' show RuntimeOfflineFirstDefinition;
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import '../brick/models/customer.model.dart';
import '../brick/models/pizza.model.dart';

part 'adapters/customer_adapter.g.dart';
part 'adapters/pizza_adapter.g.dart';

/// Rest mappings should only be used when initializing a [RestProvider]
final Map<Type, RestAdapter<RestModel>> restMappings = {
  Customer: CustomerAdapter(),
  Pizza: PizzaAdapter()
};
final restModelDictionary = RestModelDictionary(restMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Customer: CustomerAdapter(),
  Pizza: PizzaAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
