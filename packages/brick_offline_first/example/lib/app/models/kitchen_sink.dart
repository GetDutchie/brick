import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:brick_offline_first_abstract/annotations.dart';

import 'package:brick_offline_first_example/app/models/hat.dart';
import 'package:brick_offline_first_example/app/models/mounty.dart';

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: '=> "/my-path";',
    // These are NOT necessary unless other properties are present
    // Brick will find the first top-level property if there are multiple properties
    // in the return response from REST
    fromKey: 'kitchen_sinks',
    // Only necessary if the endpoint expects the payload nested within a property key
    toKey: 'kitchen_sink',
  ),
)
class KitchenSink extends OfflineFirstWithRestModel {
  final String anyString;

  final int anyInt;

  final double anyDouble;

  final num anyNum;

  final DateTime anyDateTime;

  final bool anyBool;

  final Map anyMap;

  final AnyEnum enumFromIndex;

  final List<int> anyList;

  final Set<int> anySet;

  final Mounty offlineFirstModel;

  final List<Mounty> listOfflineFirstModel;

  final Set<Mounty> setOfflineFirstModel;

  final Future<Mounty> futureOfflineFirstModel;

  final List<Future<Mounty>> futureListOfflineFirstModel;

  final Set<Future<Mounty>> futureSetOfflineFirstModel;

  final Hat offlineFirstSerdes;

  final List<Hat> listOfflineFirstSerdes;

  final Set<Hat> setOfflineFirstSerdes;

  @Rest(name: 'restAnnotationOtherName')
  final String restAnnotationName;

  @Rest(defaultValue: '"a default value"')
  final String restAnnotationDefaultValue;

  @Rest(nullable: true)
  final String restAnnotationNullable;

  @Rest(ignore: true)
  final String restAnnotationIgnore;

  @Rest(ignoreTo: true)
  final String restAnnotationIgnoreTo;

  @Rest(ignoreFrom: true)
  final String restAnnotationIgnoreFrom;

  @Rest(fromGenerator: '%DATA_PROPERTY%.toString()')
  final String restAnnotationFromGenerator;

  @Rest(toGenerator: '%INSTANCE_PROPERTY%.toString()')
  final String restAnnotationToGenerator;

  @Rest(enumAsString: true)
  final AnyEnum enumFromString;

  @Sqlite(nullable: true)
  final String sqliteAnnotationNullable;

  @Sqlite(defaultValue: '"default value"')
  final String sqliteAnnotationDefaultValue;

  @Sqlite(fromGenerator: '%DATA_PROPERTY%.toString()')
  final String sqliteAnnotationFromGenerator;

  @Sqlite(toGenerator: '%INSTANCE_PROPERTY%.toString()')
  final String sqliteAnnotationToGenerator;

  @Sqlite(ignore: true)
  final String sqliteAnnotationIgnore;

  @Sqlite(unique: true)
  final String sqliteAnnotationUnique;

  @Sqlite(name: 'custom column name')
  final String sqliteAnnotationName;

  @OfflineFirst(where: {'email': "data['mounty_email']"})
  final Mounty offlineFirstWhere;

  KitchenSink({
    required this.anyString,
    required this.anyInt,
    required this.anyDouble,
    required this.anyNum,
    required this.anyDateTime,
    required this.anyBool,
    required this.anyMap,
    required this.enumFromIndex,
    required this.anyList,
    required this.anySet,
    required this.offlineFirstModel,
    required this.listOfflineFirstModel,
    required this.setOfflineFirstModel,
    required this.futureOfflineFirstModel,
    required this.futureListOfflineFirstModel,
    required this.futureSetOfflineFirstModel,
    required this.offlineFirstSerdes,
    required this.listOfflineFirstSerdes,
    required this.setOfflineFirstSerdes,
    required this.restAnnotationName,
    required this.restAnnotationDefaultValue,
    required this.restAnnotationNullable,
    required this.restAnnotationIgnore,
    required this.restAnnotationIgnoreTo,
    required this.restAnnotationIgnoreFrom,
    required this.restAnnotationFromGenerator,
    required this.restAnnotationToGenerator,
    required this.enumFromString,
    required this.sqliteAnnotationNullable,
    required this.sqliteAnnotationDefaultValue,
    required this.sqliteAnnotationFromGenerator,
    required this.sqliteAnnotationToGenerator,
    required this.sqliteAnnotationIgnore,
    required this.sqliteAnnotationUnique,
    required this.sqliteAnnotationName,
    required this.offlineFirstWhere,
  });
}

enum AnyEnum { first, second }
