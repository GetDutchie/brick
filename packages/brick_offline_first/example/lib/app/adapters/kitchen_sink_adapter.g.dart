// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<KitchenSink> _$KitchenSinkFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return KitchenSink(
      anyString: data['any_string'] as String?,
      anyInt: data['any_int'] as int?,
      anyDouble: data['any_double'] as double?,
      anyNum: data['any_num'] as num?,
      anyDateTime: data['any_date_time'] == null
          ? null
          : DateTime.tryParse(data['any_date_time'] as String),
      anyBool: data['any_bool'] as bool?,
      anyMap: data['any_map'],
      enumFromIndex: data['enum_from_index'] is int
          ? AnyEnum.values[data['enum_from_index'] as int]
          : null,
      anyList: data['any_list'].toList().cast<int>() ?? <int>[],
      anySet: data['any_set'].toSet().cast<int>() ?? <int>{},
      offlineFirstModel: await MountyAdapter().fromRest(
          data['offline_first_model'],
          provider: provider,
          repository: repository),
      listOfflineFirstModel: await Future.wait<Mounty>(
          data['list_offline_first_model']?.map((d) => MountyAdapter().fromRest(d, provider: provider, repository: repository)).toList() ??
              []),
      setOfflineFirstModel:
          (await Future.wait<Mounty>(data['set_offline_first_model']?.map((d) => MountyAdapter().fromRest(d, provider: provider, repository: repository)).toSet() ?? []))
              .toSet(),
      offlineFirstSerdes: Hat.fromRest(data['offline_first_serdes']),
      listOfflineFirstSerdes: data['list_offline_first_serdes']
          .map((c) => Hat.fromRest(c as Map<String, dynamic>))
          .toList(),
      setOfflineFirstSerdes: data['set_offline_first_serdes']
          .map((c) => Hat.fromRest(c as Map<String, dynamic>))
          .toSet(),
      restAnnotationName: data['restAnnotationOtherName'] as String?,
      restAnnotationDefaultValue:
          data['rest_annotation_default_value'] as String? ?? 'a default value',
      restAnnotationNullable: data['rest_annotation_nullable'] == null
          ? null
          : data['rest_annotation_nullable'] as String?,
      restAnnotationIgnoreTo: data['rest_annotation_ignore_to'] as String?,
      restAnnotationFromGenerator:
          data['rest_annotation_from_generator'].toString(),
      restAnnotationToGenerator: data['rest_annotation_to_generator'] as String?,
      enumFromString: RestAdapter.enumValueFromName(AnyEnum.values, data['enum_from_string']),
      sqliteAnnotationNullable: data['sqlite_annotation_nullable'] as String?,
      sqliteAnnotationDefaultValue: data['sqlite_annotation_default_value'] as String?,
      sqliteAnnotationFromGenerator: data['sqlite_annotation_from_generator'] as String?,
      sqliteAnnotationToGenerator: data['sqlite_annotation_to_generator'] as String?,
      sqliteAnnotationIgnore: data['sqlite_annotation_ignore'] as String?,
      sqliteAnnotationUnique: data['sqlite_annotation_unique'] as String?,
      sqliteAnnotationName: data['sqlite_annotation_name'] as String?,
      offlineFirstWhere: await repository?.getAssociation<Mounty>(Query(where: [Where.exact('email', data['mounty_email'])], providerArgs: {'limit': 1})).then((r) => r?.isNotEmpty ?? false ? r!.first : null));
}

Future<Map<String, dynamic>> _$KitchenSinkToRest(KitchenSink instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'any_string': instance.anyString,
    'any_int': instance.anyInt,
    'any_double': instance.anyDouble,
    'any_num': instance.anyNum,
    'any_date_time': instance.anyDateTime?.toIso8601String(),
    'any_bool': instance.anyBool,
    'any_map': instance.anyMap,
    'enum_from_index': instance.enumFromIndex != null
        ? AnyEnum.values.indexOf(instance.enumFromIndex!)
        : null,
    'any_list': instance.anyList,
    'any_set': instance.anySet,
    'offline_first_model': instance.offlineFirstModel != null
        ? await MountyAdapter().toRest(instance.offlineFirstModel!,
            provider: provider, repository: repository)
        : null,
    'list_offline_first_model': await Future.wait<Map<String, dynamic>>(instance
            .listOfflineFirstModel
            ?.map((s) => MountyAdapter()
                .toRest(s, provider: provider, repository: repository))
            .toList() ??
        []),
    'set_offline_first_model': await Future.wait<Map<String, dynamic>>(instance
            .setOfflineFirstModel
            ?.map((s) => MountyAdapter()
                .toRest(s, provider: provider, repository: repository))
            .toList() ??
        []),
    'offline_first_serdes': instance.offlineFirstSerdes?.toRest(),
    'list_offline_first_serdes':
        instance.listOfflineFirstSerdes?.map((Hat c) => c.toRest()).toList(),
    'set_offline_first_serdes':
        instance.setOfflineFirstSerdes?.map((Hat c) => c.toRest()).toList(),
    'restAnnotationOtherName': instance.restAnnotationName,
    'rest_annotation_default_value': instance.restAnnotationDefaultValue,
    'rest_annotation_nullable': instance.restAnnotationNullable,
    'rest_annotation_ignore_from': instance.restAnnotationIgnoreFrom,
    'rest_annotation_from_generator': instance.restAnnotationFromGenerator,
    'rest_annotation_to_generator':
        instance.restAnnotationToGenerator.toString(),
    'enum_from_string': instance.enumFromString?.toString().split('.').last,
    'sqlite_annotation_nullable': instance.sqliteAnnotationNullable,
    'sqlite_annotation_default_value': instance.sqliteAnnotationDefaultValue,
    'sqlite_annotation_from_generator': instance.sqliteAnnotationFromGenerator,
    'sqlite_annotation_to_generator': instance.sqliteAnnotationToGenerator,
    'sqlite_annotation_ignore': instance.sqliteAnnotationIgnore,
    'sqlite_annotation_unique': instance.sqliteAnnotationUnique,
    'sqlite_annotation_name': instance.sqliteAnnotationName,
    'offline_first_where': instance.offlineFirstWhere?.email
  };
}

Future<KitchenSink> _$KitchenSinkFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return KitchenSink(
      anyString:
          data['any_string'] == null ? null : data['any_string'] as String?,
      anyInt: data['any_int'] == null ? null : data['any_int'] as int?,
      anyDouble:
          data['any_double'] == null ? null : data['any_double'] as double?,
      anyNum: data['any_num'] == null ? null : data['any_num'] as num?,
      anyDateTime: data['any_date_time'] == null
          ? null
          : data['any_date_time'] == null
              ? null
              : DateTime.tryParse(data['any_date_time'] as String),
      anyBool: data['any_bool'] == null ? null : data['any_bool'] == 1,
      anyMap: data['any_map'] == null ? null : jsonDecode(data['any_map']),
      enumFromIndex: data['enum_from_index'] == null
          ? null
          : (data['enum_from_index'] > -1
              ? AnyEnum.values[data['enum_from_index'] as int]
              : null),
      anyList: data['any_list'] == null
          ? null
          : jsonDecode(data['any_list']).toList().cast<int>(),
      anySet: data['any_set'] == null
          ? null
          : jsonDecode(data['any_set']).toSet().cast<int>(),
      offlineFirstModel: data['offline_first_model_Mounty_brick_id'] == null
          ? null
          : (data['offline_first_model_Mounty_brick_id'] > -1
              ? (await repository?.getAssociation<Mounty>(
                  Query.where('primaryKey',
                      data['offline_first_model_Mounty_brick_id'] as int,
                      limit1: true),
                ))
                  ?.first
              : null),
      listOfflineFirstModel: (await provider
              .rawQuery('SELECT DISTINCT `f_Mounty_brick_id` FROM `_brick_KitchenSink_list_offline_first_model` WHERE l_KitchenSink_brick_id = ?',
                  [data['_brick_id'] as int]).then((results) {
        final ids = results.map((r) => r['f_Mounty_brick_id']);
        return Future.wait<Mounty>(ids.map((primaryKey) => repository!
            .getAssociation<Mounty>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toList(),
      setOfflineFirstModel: (await provider
              .rawQuery('SELECT DISTINCT `f_Mounty_brick_id` FROM `_brick_KitchenSink_set_offline_first_model` WHERE l_KitchenSink_brick_id = ?',
                  [data['_brick_id'] as int]).then((results) {
        final ids = results.map((r) => r['f_Mounty_brick_id']);
        return Future.wait<Mounty>(ids.map((primaryKey) => repository!
            .getAssociation<Mounty>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toSet(),
      offlineFirstSerdes: data['offline_first_serdes'] == null
          ? null
          : Hat?.fromSqlite(data['offline_first_serdes'] as String),
      listOfflineFirstSerdes: data['list_offline_first_serdes'] == null
          ? null
          : jsonDecode(data['list_offline_first_serdes']).map((c) => Hat.fromSqlite(c as String)).toList(),
      setOfflineFirstSerdes: data['set_offline_first_serdes'] == null ? null : jsonDecode(data['set_offline_first_serdes']).map((c) => Hat.fromSqlite(c as String)).toSet(),
      restAnnotationName: data['rest_annotation_name'] == null ? null : data['rest_annotation_name'] as String?,
      restAnnotationDefaultValue: data['rest_annotation_default_value'] == null ? null : data['rest_annotation_default_value'] as String?,
      restAnnotationNullable: data['rest_annotation_nullable'] == null ? null : data['rest_annotation_nullable'] as String?,
      restAnnotationIgnore: data['rest_annotation_ignore'] == null ? null : data['rest_annotation_ignore'] as String?,
      restAnnotationIgnoreTo: data['rest_annotation_ignore_to'] == null ? null : data['rest_annotation_ignore_to'] as String?,
      restAnnotationIgnoreFrom: data['rest_annotation_ignore_from'] == null ? null : data['rest_annotation_ignore_from'] as String?,
      restAnnotationFromGenerator: data['rest_annotation_from_generator'] == null ? null : data['rest_annotation_from_generator'] as String?,
      restAnnotationToGenerator: data['rest_annotation_to_generator'] == null ? null : data['rest_annotation_to_generator'] as String?,
      enumFromString: data['enum_from_string'] == null ? null : (data['enum_from_string'] > -1 ? AnyEnum.values[data['enum_from_string'] as int] : null),
      sqliteAnnotationNullable: data['sqlite_annotation_nullable'] == null ? null : data['sqlite_annotation_nullable'] as String?,
      sqliteAnnotationDefaultValue: data['sqlite_annotation_default_value'] == null ? null : data['sqlite_annotation_default_value'] as String? ?? 'default value',
      sqliteAnnotationFromGenerator: data['sqlite_annotation_from_generator'] == null ? null : data['sqlite_annotation_from_generator'].toString(),
      sqliteAnnotationToGenerator: data['sqlite_annotation_to_generator'] == null ? null : data['sqlite_annotation_to_generator'] as String?,
      sqliteAnnotationUnique: data['sqlite_annotation_unique'] == null ? null : data['sqlite_annotation_unique'] as String?,
      sqliteAnnotationName: data['custom column name'] == null ? null : data['custom column name'] as String?,
      offlineFirstWhere: data['offline_first_where_Mounty_brick_id'] == null
          ? null
          : (data['offline_first_where_Mounty_brick_id'] > -1
              ? (await repository?.getAssociation<Mounty>(
                  Query.where('primaryKey',
                      data['offline_first_where_Mounty_brick_id'] as int,
                      limit1: true),
                ))
                  ?.first
              : null))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$KitchenSinkToSqlite(KitchenSink instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'any_string': instance.anyString,
    'any_int': instance.anyInt,
    'any_double': instance.anyDouble,
    'any_num': instance.anyNum,
    'any_date_time': instance.anyDateTime?.toIso8601String(),
    'any_bool': instance.anyBool == null ? null : (instance.anyBool! ? 1 : 0),
    'any_map': jsonEncode(instance.anyMap ?? {}),
    'enum_from_index': instance.enumFromIndex != null
        ? AnyEnum.values.indexOf(instance.enumFromIndex!)
        : null,
    'any_list': jsonEncode(instance.anyList ?? []),
    'any_set': jsonEncode(instance.anySet?.toList() ?? []),
    'offline_first_model_Mounty_brick_id': instance.offlineFirstModel != null
        ? instance.offlineFirstModel!.primaryKey ??
            await provider.upsert<Mounty>(instance.offlineFirstModel!,
                repository: repository)
        : null,
    'offline_first_serdes': instance.offlineFirstSerdes?.toSqlite(),
    'list_offline_first_serdes': jsonEncode(instance.listOfflineFirstSerdes
            ?.map((Hat c) => c.toSqlite())
            .toList() ??
        []),
    'set_offline_first_serdes': jsonEncode(
        instance.setOfflineFirstSerdes?.map((Hat c) => c.toSqlite()).toList() ??
            []),
    'rest_annotation_name': instance.restAnnotationName,
    'rest_annotation_default_value': instance.restAnnotationDefaultValue,
    'rest_annotation_nullable': instance.restAnnotationNullable,
    'rest_annotation_ignore': instance.restAnnotationIgnore,
    'rest_annotation_ignore_to': instance.restAnnotationIgnoreTo,
    'rest_annotation_ignore_from': instance.restAnnotationIgnoreFrom,
    'rest_annotation_from_generator': instance.restAnnotationFromGenerator,
    'rest_annotation_to_generator': instance.restAnnotationToGenerator,
    'enum_from_string': instance.enumFromString != null
        ? AnyEnum.values.indexOf(instance.enumFromString!)
        : null,
    'sqlite_annotation_nullable': instance.sqliteAnnotationNullable,
    'sqlite_annotation_default_value': instance.sqliteAnnotationDefaultValue,
    'sqlite_annotation_from_generator': instance.sqliteAnnotationFromGenerator,
    'sqlite_annotation_to_generator':
        instance.sqliteAnnotationToGenerator.toString(),
    'sqlite_annotation_unique': instance.sqliteAnnotationUnique,
    'custom column name': instance.sqliteAnnotationName,
    'offline_first_where_Mounty_brick_id': instance.offlineFirstWhere != null
        ? instance.offlineFirstWhere!.primaryKey ??
            await provider.upsert<Mounty>(instance.offlineFirstWhere!,
                repository: repository)
        : null
  };
}

/// Construct a [KitchenSink]
class KitchenSinkAdapter extends OfflineFirstWithRestAdapter<KitchenSink> {
  KitchenSinkAdapter();

  @override
  String? restEndpoint({query, instance}) => '/my-path';
  @override
  final String? fromKey = 'kitchen_sinks';
  @override
  final String? toKey = 'kitchen_sink';
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'anyString': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'any_string',
      iterable: false,
      type: String,
    ),
    'anyInt': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'any_int',
      iterable: false,
      type: int,
    ),
    'anyDouble': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'any_double',
      iterable: false,
      type: double,
    ),
    'anyNum': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'any_num',
      iterable: false,
      type: num,
    ),
    'anyDateTime': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'any_date_time',
      iterable: false,
      type: DateTime,
    ),
    'anyBool': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'any_bool',
      iterable: false,
      type: bool,
    ),
    'anyMap': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'any_map',
      iterable: false,
      type: Map,
    ),
    'enumFromIndex': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'enum_from_index',
      iterable: false,
      type: AnyEnum,
    ),
    'anyList': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'any_list',
      iterable: true,
      type: int,
    ),
    'anySet': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'any_set',
      iterable: true,
      type: int,
    ),
    'offlineFirstModel': RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'offline_first_model_Mounty_brick_id',
      iterable: false,
      type: Mounty,
    ),
    'listOfflineFirstModel': RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'list_offline_first_model',
      iterable: true,
      type: Mounty,
    ),
    'setOfflineFirstModel': RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'set_offline_first_model',
      iterable: true,
      type: Mounty,
    ),
    'offlineFirstSerdes': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'offline_first_serdes',
      iterable: false,
      type: Hat,
    ),
    'listOfflineFirstSerdes': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'list_offline_first_serdes',
      iterable: true,
      type: Hat,
    ),
    'setOfflineFirstSerdes': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'set_offline_first_serdes',
      iterable: true,
      type: Hat,
    ),
    'restAnnotationName': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'rest_annotation_name',
      iterable: false,
      type: String,
    ),
    'restAnnotationDefaultValue': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'rest_annotation_default_value',
      iterable: false,
      type: String,
    ),
    'restAnnotationNullable': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'rest_annotation_nullable',
      iterable: false,
      type: String,
    ),
    'restAnnotationIgnore': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'rest_annotation_ignore',
      iterable: false,
      type: String,
    ),
    'restAnnotationIgnoreTo': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'rest_annotation_ignore_to',
      iterable: false,
      type: String,
    ),
    'restAnnotationIgnoreFrom': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'rest_annotation_ignore_from',
      iterable: false,
      type: String,
    ),
    'restAnnotationFromGenerator': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'rest_annotation_from_generator',
      iterable: false,
      type: String,
    ),
    'restAnnotationToGenerator': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'rest_annotation_to_generator',
      iterable: false,
      type: String,
    ),
    'enumFromString': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'enum_from_string',
      iterable: false,
      type: AnyEnum,
    ),
    'sqliteAnnotationNullable': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sqlite_annotation_nullable',
      iterable: false,
      type: String,
    ),
    'sqliteAnnotationDefaultValue': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sqlite_annotation_default_value',
      iterable: false,
      type: String,
    ),
    'sqliteAnnotationFromGenerator': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sqlite_annotation_from_generator',
      iterable: false,
      type: String,
    ),
    'sqliteAnnotationToGenerator': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sqlite_annotation_to_generator',
      iterable: false,
      type: String,
    ),
    'sqliteAnnotationUnique': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sqlite_annotation_unique',
      iterable: false,
      type: String,
    ),
    'sqliteAnnotationName': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'custom column name',
      iterable: false,
      type: String,
    ),
    'offlineFirstWhere': RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'offline_first_where_Mounty_brick_id',
      iterable: false,
      type: Mounty,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
      KitchenSink instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `KitchenSink` WHERE sqlite_annotation_unique = ? LIMIT 1''',
        [instance.sqliteAnnotationUnique]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'KitchenSink';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int?>(instance.listOfflineFirstModel?.map((s) async {
            final id = s.primaryKey ??
                await provider.upsert<Mounty>(s, repository: repository);
            return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_KitchenSink_list_offline_first_model` (`l_KitchenSink_brick_id`, `f_Mounty_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id]);
          }) ??
          []);
    }

    if (instance.primaryKey != null) {
      await Future.wait<int?>(instance.setOfflineFirstModel?.map((s) async {
            final id = s.primaryKey ??
                await provider.upsert<Mounty>(s, repository: repository);
            return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_KitchenSink_set_offline_first_model` (`l_KitchenSink_brick_id`, `f_Mounty_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id]);
          }) ??
          []);
    }
  }

  @override
  Future<KitchenSink> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$KitchenSinkFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(KitchenSink input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$KitchenSinkToRest(input,
          provider: provider, repository: repository);
  @override
  Future<KitchenSink> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$KitchenSinkFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(KitchenSink input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$KitchenSinkToSqlite(input,
          provider: provider, repository: repository);
}
