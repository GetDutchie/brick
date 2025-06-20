// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/query.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/db.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/brick_sqlite.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_supabase/brick_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:pizza_shoppe/brick/models/finance_provider.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:pizza_shoppe/brick/models/inventory.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:pizza_shoppe/brick/models/customer.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:pizza_shoppe/brick/models/branch.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:pizza_shoppe/brick/models/financing.model.dart';// GENERATED CODE DO NOT EDIT
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/brick_sqlite.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary, RuntimeSqliteColumnDefinition, SqliteProvider;
import 'package:brick_supabase/brick_supabase.dart' show SupabaseProvider, SupabaseModel, SupabaseAdapter, SupabaseModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first/brick_offline_first.dart' show RuntimeOfflineFirstDefinition;
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import '../brick/models/financing.model.dart';
import '../brick/models/branch.model.dart';
import '../brick/models/transactionItem.model.dart';
import '../brick/models/customer.model.dart';
import '../brick/models/pizza.model.dart';
import '../brick/models/finance_provider.model.dart';
import '../brick/models/inventory.model.dart';

part 'adapters/financing_adapter.g.dart';
part 'adapters/branch_adapter.g.dart';
part 'adapters/transaction_item_adapter.g.dart';
part 'adapters/customer_adapter.g.dart';
part 'adapters/pizza_adapter.g.dart';
part 'adapters/finance_provider_adapter.g.dart';
part 'adapters/inventory_adapter.g.dart';

/// Supabase mappings should only be used when initializing a [SupabaseProvider]
final Map<Type, SupabaseAdapter<SupabaseModel>> supabaseMappings = {
  Financing: FinancingAdapter(),
  Branch: BranchAdapter(),
  TransactionItem: TransactionItemAdapter(),
  Customer: CustomerAdapter(),
  Pizza: PizzaAdapter(),
  FinanceProvider: FinanceProviderAdapter(),
  Inventory: InventoryAdapter()
};
final supabaseModelDictionary = SupabaseModelDictionary(supabaseMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Financing: FinancingAdapter(),
  Branch: BranchAdapter(),
  TransactionItem: TransactionItemAdapter(),
  Customer: CustomerAdapter(),
  Pizza: PizzaAdapter(),
  FinanceProvider: FinanceProviderAdapter(),
  Inventory: InventoryAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
