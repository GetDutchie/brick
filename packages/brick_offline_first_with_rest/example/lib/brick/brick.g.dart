// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/query.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/db.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/core.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_rest/brick_rest.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/brick_sqlite.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_rest_example/brick/models/hat.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_rest_example/brick/models/mounty.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first/brick_offline_first.dart'
    show OfflineFirstSerdes; // GENERATED CODE DO NOT EDIT
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

import '../brick/models/kitchen_sink.model.dart';
import '../brick/models/horse.model.dart';

part 'adapters/kitchen_sink_adapter.g.dart';
part 'adapters/mounty_adapter.g.dart';
part 'adapters/horse_adapter.g.dart';

/// Rest mappings should only be used when initializing a [RestProvider]
final Map<Type, RestAdapter<RestModel>> restMappings = {
  KitchenSink: KitchenSinkAdapter(),
  Mounty: MountyAdapter(),
  Horse: HorseAdapter()
};
final restModelDictionary = RestModelDictionary(restMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  KitchenSink: KitchenSinkAdapter(),
  Mounty: MountyAdapter(),
  Horse: HorseAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
