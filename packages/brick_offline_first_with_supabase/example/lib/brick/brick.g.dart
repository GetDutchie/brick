// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/query.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/db.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_supabase_example/models/mounty.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/brick_sqlite.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_supabase/brick_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_supabase_example/models/hat.dart'; // GENERATED CODE DO NOT EDIT
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/brick_sqlite.dart'
    show
        SqliteModel,
        SqliteAdapter,
        SqliteModelDictionary,
        RuntimeSqliteColumnDefinition,
        SqliteProvider;
import 'package:brick_supabase/brick_supabase.dart'
    show SupabaseProvider, SupabaseModel, SupabaseAdapter, SupabaseModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first/brick_offline_first.dart' show RuntimeOfflineFirstDefinition;
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import '../models/kitchen_sink.model.dart';
import '../models/mounty.model.dart';
import '../models/horse.model.dart';

part 'adapters/kitchen_sink_adapter.g.dart';
part 'adapters/mounty_adapter.g.dart';
part 'adapters/horse_adapter.g.dart';

/// Supabase mappings should only be used when initializing a [SupabaseProvider]
final Map<Type, SupabaseAdapter<SupabaseModel>> supabaseMappings = {
  KitchenSink: KitchenSinkAdapter(),
  Mounty: MountyAdapter(),
  Horse: HorseAdapter()
};
final supabaseModelDictionary = SupabaseModelDictionary(supabaseMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  KitchenSink: KitchenSinkAdapter(),
  Mounty: MountyAdapter(),
  Horse: HorseAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
