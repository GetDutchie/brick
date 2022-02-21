// ignore: unused_import, unused_shown_name
import 'package:brick_sqlite_abstract/db.dart';
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first_with_rest/offline_first_with_rest.dart';
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first_with_rest_example/brick/models/mounty.dart';
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first_abstract/abstract.dart' show OfflineFirstSerdes;
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first_with_rest_example/brick/models/hat.dart'; // GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/sqlite.dart'
    show SqliteModel, SqliteAdapter, SqliteModelDictionary, RuntimeSqliteColumnDefinition;
import 'package:brick_rest/rest.dart'
    show RestProvider, RestModel, RestAdapter, RestModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;
import 'package:brick_sqlite/sqlite.dart' show SqliteProvider;
import 'package:brick_core/query.dart';

import 'models/horse.dart';
import 'models/kitchen_sink.dart';
import 'models/mounty.dart';

part 'adapters/horse_adapter.g.dart';
part 'adapters/kitchen_sink_adapter.g.dart';
part 'adapters/mounty_adapter.g.dart';

/// REST mappings should only be used when initializing a [RestProvider]
final Map<Type, RestAdapter<RestModel>> restMappings = {
  Horse: HorseAdapter(),
  KitchenSink: KitchenSinkAdapter(),
  Mounty: MountyAdapter()
};
final restModelDictionary = RestModelDictionary(restMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Horse: HorseAdapter(),
  KitchenSink: KitchenSinkAdapter(),
  Mounty: MountyAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
