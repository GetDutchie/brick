// ignore_for_file: always_use_package_imports

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';

import 'hat.dart';
import 'mounty.model.dart';

@ConnectOfflineFirstWithSupabase()
class KitchenSink extends OfflineFirstWithSupabaseModel {
  final String? anyString;

  final int? anyInt;

  final double? anyDouble;

  final num? anyNum;

  final DateTime? anyDateTime;

  final bool? anyBool;

  final Map? anyMap;

  final AnyEnum? enumFromIndex;

  final List<int>? anyList;

  final Set<int>? anySet;

  final Mounty? offlineFirstModel;

  final List<Mounty>? listOfflineFirstModel;

  final Set<Mounty>? setOfflineFirstModel;

  final Hat? offlineFirstSerdes;

  final List<Hat>? listOfflineFirstSerdes;

  final Set<Hat>? setOfflineFirstSerdes;

  @Supabase(name: 'restAnnotationOtherName')
  final String? restAnnotationName;

  @Supabase(defaultValue: "'a default value'")
  final String? restAnnotationDefaultValue;

  final String? restAnnotationNullable;

  @Supabase(ignore: true)
  final String? restAnnotationIgnore;

  @Supabase(ignoreTo: true)
  final String? restAnnotationIgnoreTo;

  @Supabase(ignoreFrom: true)
  final String? restAnnotationIgnoreFrom;

  @Supabase(fromGenerator: '%DATA_PROPERTY%.toString()')
  final String? restAnnotationFromGenerator;

  @Supabase(toGenerator: '%INSTANCE_PROPERTY%.toString()')
  final String? restAnnotationToGenerator;

  @Supabase(enumAsString: true)
  final AnyEnum? enumFromString;

  final String? sqliteAnnotationNullable;

  @Sqlite(defaultValue: "'default value'")
  final String? sqliteAnnotationDefaultValue;

  @Sqlite(fromGenerator: '%DATA_PROPERTY%.toString()')
  final String? sqliteAnnotationFromGenerator;

  @Sqlite(toGenerator: '%INSTANCE_PROPERTY%.toString()')
  final String? sqliteAnnotationToGenerator;

  @Sqlite(ignore: true)
  final String? sqliteAnnotationIgnore;

  @Sqlite(unique: true)
  final String? sqliteAnnotationUnique;

  @Sqlite(name: 'custom column name')
  final String? sqliteAnnotationName;

  @OfflineFirst(where: {'email': "data['mounty_email']"})
  final Mounty? offlineFirstWhere;

  KitchenSink({
    this.anyString,
    this.anyInt,
    this.anyDouble,
    this.anyNum,
    this.anyDateTime,
    this.anyBool,
    this.anyMap,
    this.enumFromIndex,
    this.anyList,
    this.anySet,
    this.offlineFirstModel,
    this.listOfflineFirstModel,
    this.setOfflineFirstModel,
    this.offlineFirstSerdes,
    this.listOfflineFirstSerdes,
    this.setOfflineFirstSerdes,
    this.restAnnotationName,
    this.restAnnotationDefaultValue,
    this.restAnnotationNullable,
    this.restAnnotationIgnore,
    this.restAnnotationIgnoreTo,
    this.restAnnotationIgnoreFrom,
    this.restAnnotationFromGenerator,
    this.restAnnotationToGenerator,
    this.enumFromString,
    this.sqliteAnnotationNullable,
    this.sqliteAnnotationDefaultValue,
    this.sqliteAnnotationFromGenerator,
    this.sqliteAnnotationToGenerator,
    this.sqliteAnnotationIgnore,
    this.sqliteAnnotationUnique,
    this.sqliteAnnotationName,
    this.offlineFirstWhere,
  });
}

enum AnyEnum { first, second }
