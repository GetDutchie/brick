// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<KitchenSink> _$KitchenSinkFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstWithRestRepository repository}) async {
  return KitchenSink(
      anyString: data['any_string'] as String,
      anyInt: data['any_int'] as int,
      anyDouble: data['any_double'] as double,
      anyNum: data['any_num'] as num,
      anyDateTime: data['any_date_time'] == null
          ? null
          : DateTime.tryParse(data['any_date_time'] as String),
      anyBool: data['any_bool'] as bool,
      anyMap: data['any_map'],
      enumFromIndex: data['enum_from_index'] is int
          ? AnyEnum.values[data['enum_from_index'] as int]
          : null,
      anyList: data['any_list']?.toList()?.cast<int>() ?? <int>[],
      anySet: data['any_set']?.toSet()?.cast<int>() ?? <int>{},
      offlineFirstModel: await MountyAdapter().fromRest(data['offline_first_model'],
          provider: provider, repository: repository),
      listOfflineFirstModel: await Future.wait<Mounty>(
          data['list_offline_first_model']?.map((d) => MountyAdapter().fromRest(d, provider: provider, repository: repository))?.toList()?.cast<Future<Mounty>>() ??
              []),
      setOfflineFirstModel:
          (await Future.wait<Mounty>(data['set_offline_first_model']?.map((d) => MountyAdapter().fromRest(d, provider: provider, repository: repository))?.toSet()?.cast<Future<Mounty>>() ?? []))
              ?.toSet(),
      futureOfflineFirstModel: MountyAdapter().fromRest(
          data['future_offline_first_model'],
          provider: provider,
          repository: repository),
      futureListOfflineFirstModel: data['future_list_offline_first_model']
          ?.map((d) =>
              MountyAdapter().fromRest(d, provider: provider, repository: repository))
          ?.toList()
          ?.cast<Future<Mounty>>(),
      futureSetOfflineFirstModel: (data['future_set_offline_first_model']?.map((d) => MountyAdapter().fromRest(d, provider: provider, repository: repository))?.toSet()?.cast<Future<Mounty>>())?.toSet(),
      offlineFirstSerdes: Hat.fromRest(data['offline_first_serdes']),
      listOfflineFirstSerdes: data['list_offline_first_serdes'].map((c) => Hat.fromRest(c as Map<String, dynamic>))?.toList()?.cast<Hat>(),
      setOfflineFirstSerdes: data['set_offline_first_serdes'].map((c) => Hat.fromRest(c as Map<String, dynamic>))?.toSet()?.cast<Hat>(),
      restAnnotationName: data['restAnnotationOtherName'] as String,
      restAnnotationDefaultValue: data['rest_annotation_default_value'] as String ?? "a default value",
      restAnnotationNullable: data['rest_annotation_nullable'] == null ? null : data['rest_annotation_nullable'] as String,
      restAnnotationIgnoreTo: data['rest_annotation_ignore_to'] as String,
      restAnnotationFromGenerator: data['rest_annotation_from_generator'].toString(),
      restAnnotationToGenerator: data['rest_annotation_to_generator'] as String,
      enumFromString: AnyEnum.values.firstWhere((h) => h.toString().split('.').last == data['enum_from_string'], orElse: () => null),
      sqliteAnnotationNullable: data['sqlite_annotation_nullable'] as String,
      sqliteAnnotationDefaultValue: data['sqlite_annotation_default_value'] as String,
      sqliteAnnotationFromGenerator: data['sqlite_annotation_from_generator'] as String,
      sqliteAnnotationToGenerator: data['sqlite_annotation_to_generator'] as String,
      sqliteAnnotationIgnore: data['sqlite_annotation_ignore'] as String,
      sqliteAnnotationUnique: data['sqlite_annotation_unique'] as String,
      sqliteAnnotationName: data['sqlite_annotation_name'] as String,
      offlineFirstWhere: await repository?.getAssociation<Mounty>(Query(where: [Where.exact('email', data['mounty_email'])], providerArgs: {'limit': 1}))?.then((a) => a?.isNotEmpty == true ? a.first : null));
}

Future<Map<String, dynamic>> _$KitchenSinkToRest(KitchenSink instance,
    {RestProvider provider, OfflineFirstWithRestRepository repository}) async {
  return {
    'any_string': instance.anyString,
    'any_int': instance.anyInt,
    'any_double': instance.anyDouble,
    'any_num': instance.anyNum,
    'any_date_time': instance.anyDateTime?.toIso8601String(),
    'any_bool': instance.anyBool,
    'any_map': instance.anyMap,
    'enum_from_index': instance.enumFromIndex != null
        ? AnyEnum.values.indexOf(instance.enumFromIndex)
        : null,
    'any_list': instance.anyList,
    'any_set': instance.anySet,
    'offline_first_model':
        await MountyAdapter().toRest(instance.offlineFirstModel),
    'list_offline_first_model': await Future.wait<Map<String, dynamic>>(instance
            .listOfflineFirstModel
            ?.map((s) => MountyAdapter().toRest(s))
            ?.toList() ??
        []),
    'set_offline_first_model': await Future.wait<Map<String, dynamic>>(instance
            .setOfflineFirstModel
            ?.map((s) => MountyAdapter().toRest(s))
            ?.toList() ??
        []),
    'future_offline_first_model':
        await MountyAdapter().toRest((await instance.futureOfflineFirstModel)),
    'future_list_offline_first_model': await Future.wait<Map<String, dynamic>>(
        instance.futureListOfflineFirstModel
                ?.map((s) async => MountyAdapter().toRest((await s)))
                ?.toList() ??
            []),
    'future_set_offline_first_model': await Future.wait<Map<String, dynamic>>(
        instance.futureSetOfflineFirstModel
                ?.map((s) async => MountyAdapter().toRest((await s)))
                ?.toList() ??
            []),
    'offline_first_serdes': instance.offlineFirstSerdes?.toRest(),
    'list_offline_first_serdes':
        instance.listOfflineFirstSerdes?.map((Hat c) => c?.toRest())?.toList(),
    'set_offline_first_serdes':
        instance.setOfflineFirstSerdes?.map((Hat c) => c?.toRest())?.toList(),
    'restAnnotationOtherName': instance.restAnnotationName,
    'rest_annotation_default_value': instance.restAnnotationDefaultValue,
    'rest_annotation_nullable': instance.restAnnotationNullable,
    'rest_annotation_ignore_from': instance.restAnnotationIgnoreFrom,
    'rest_annotation_from_generator': instance.restAnnotationFromGenerator,
    'rest_annotation_to_generator':
        instance.restAnnotationToGenerator.toString(),
    'enum_from_string': instance.enumFromString?.toString()?.split('.')?.last,
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
    {SqliteProvider provider,
    OfflineFirstWithRestRepository repository}) async {
  return KitchenSink(
      anyString:
          data['any_string'] == null ? null : data['any_string'] as String,
      anyInt: data['any_int'] == null ? null : data['any_int'] as int,
      anyDouble:
          data['any_double'] == null ? null : data['any_double'] as double,
      anyNum: data['any_num'] == null ? null : data['any_num'] as num,
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
          : jsonDecode(data['any_list'])?.toList()?.cast<int>(),
      anySet: data['any_set'] == null
          ? null
          : jsonDecode(data['any_set'])?.toSet()?.cast<int>(),
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
              ?.rawQuery('SELECT `Mounty_brick_id` FROM `_brick_KitchenSink_list_offline_first_model` WHERE KitchenSink_brick_id = ?',
                  [data['_brick_id'] as int])?.then((results) {
        final ids = results.map((r) => (r ?? {})['Mounty_brick_id']);
        return Future.wait<Mounty>(ids.map((primaryKey) => repository
            ?.getAssociation<Mounty>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
      }))
          ?.toList()
          ?.cast<Mounty>(),
      setOfflineFirstModel: (await provider
              ?.rawQuery('SELECT `Mounty_brick_id` FROM `_brick_KitchenSink_set_offline_first_model` WHERE KitchenSink_brick_id = ?',
                  [data['_brick_id'] as int])?.then((results) {
        final ids = results.map((r) => (r ?? {})['Mounty_brick_id']);
        return Future.wait<Mounty>(ids.map((primaryKey) => repository
            ?.getAssociation<Mounty>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
      }))
          .toSet()
          .cast<Mounty>(),
      futureOfflineFirstModel:
          data['future_offline_first_model_Mounty_brick_id'] == null
              ? null
              : (data['future_offline_first_model_Mounty_brick_id'] > -1
                  ? repository
                      ?.getAssociation<Mounty>(
                        Query.where(
                            'primaryKey',
                            data['future_offline_first_model_Mounty_brick_id']
                                as int,
                            limit1: true),
                      )
                      ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)
                  : null),
      futureListOfflineFirstModel: await provider
          ?.rawQuery('SELECT `Mounty_brick_id` FROM `_brick_KitchenSink_future_list_offline_first_model` WHERE KitchenSink_brick_id = ?', [data['_brick_id'] as int])?.then((results) {
        final ids = results.map((r) => (r ?? {})['Mounty_brick_id']);
        return ids.map((primaryKey) => repository
            ?.getAssociation<Mounty>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)).toList().cast<Future<Mounty>>();
      }),
      futureSetOfflineFirstModel: await provider?.rawQuery('SELECT `Mounty_brick_id` FROM `_brick_KitchenSink_future_set_offline_first_model` WHERE KitchenSink_brick_id = ?', [data['_brick_id'] as int])?.then((results) {
        final ids = results.map((r) => (r ?? {})['Mounty_brick_id']);
        return ids.map((primaryKey) => repository
            ?.getAssociation<Mounty>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)).toSet().cast<Future<Mounty>>();
      }),
      offlineFirstSerdes: data['offline_first_serdes'] == null ? null : Hat.fromSqlite(data['offline_first_serdes'] as String),
      listOfflineFirstSerdes: data['list_offline_first_serdes'] == null ? null : jsonDecode(data['list_offline_first_serdes']).map((c) => Hat.fromSqlite(c as String))?.toList()?.cast<Hat>(),
      setOfflineFirstSerdes: data['set_offline_first_serdes'] == null ? null : jsonDecode(data['set_offline_first_serdes']).map((c) => Hat.fromSqlite(c as String))?.toSet()?.cast<Hat>(),
      restAnnotationName: data['rest_annotation_name'] == null ? null : data['rest_annotation_name'] as String,
      restAnnotationDefaultValue: data['rest_annotation_default_value'] == null ? null : data['rest_annotation_default_value'] as String,
      restAnnotationNullable: data['rest_annotation_nullable'] == null ? null : data['rest_annotation_nullable'] as String,
      restAnnotationIgnore: data['rest_annotation_ignore'] == null ? null : data['rest_annotation_ignore'] as String,
      restAnnotationIgnoreTo: data['rest_annotation_ignore_to'] == null ? null : data['rest_annotation_ignore_to'] as String,
      restAnnotationIgnoreFrom: data['rest_annotation_ignore_from'] == null ? null : data['rest_annotation_ignore_from'] as String,
      restAnnotationFromGenerator: data['rest_annotation_from_generator'] == null ? null : data['rest_annotation_from_generator'] as String,
      restAnnotationToGenerator: data['rest_annotation_to_generator'] == null ? null : data['rest_annotation_to_generator'] as String,
      enumFromString: data['enum_from_string'] == null ? null : (data['enum_from_string'] > -1 ? AnyEnum.values[data['enum_from_string'] as int] : null),
      sqliteAnnotationNullable: data['sqlite_annotation_nullable'] == null ? null : data['sqlite_annotation_nullable'] as String,
      sqliteAnnotationDefaultValue: data['sqlite_annotation_default_value'] == null ? null : data['sqlite_annotation_default_value'] as String ?? "default value",
      sqliteAnnotationFromGenerator: data['sqlite_annotation_from_generator'] == null ? null : data['sqlite_annotation_from_generator'].toString(),
      sqliteAnnotationToGenerator: data['sqlite_annotation_to_generator'] == null ? null : data['sqlite_annotation_to_generator'] as String,
      sqliteAnnotationUnique: data['sqlite_annotation_unique'] == null ? null : data['sqlite_annotation_unique'] as String,
      sqliteAnnotationName: data['custom column name'] == null ? null : data['custom column name'] as String,
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
    {SqliteProvider provider,
    OfflineFirstWithRestRepository repository}) async {
  return {
    'any_string': instance.anyString,
    'any_int': instance.anyInt,
    'any_double': instance.anyDouble,
    'any_num': instance.anyNum,
    'any_date_time': instance.anyDateTime?.toIso8601String(),
    'any_bool': instance.anyBool == null ? null : (instance.anyBool ? 1 : 0),
    'any_map': jsonEncode(instance.anyMap ?? {}),
    'enum_from_index': AnyEnum.values.indexOf(instance.enumFromIndex),
    'any_list': jsonEncode(instance.anyList ?? []),
    'any_set': jsonEncode(instance.anySet?.toList() ?? []),
    'offline_first_model_Mounty_brick_id':
        instance.offlineFirstModel?.primaryKey ??
            await provider?.upsert<Mounty>(instance.offlineFirstModel,
                repository: repository),
    'set_offline_first_model':
        jsonEncode(instance.setOfflineFirstModel?.toList() ?? []),
    'future_offline_first_model_Mounty_brick_id':
        (await instance.futureOfflineFirstModel)?.primaryKey ??
            await provider?.upsert<Mounty>(
                (await instance.futureOfflineFirstModel),
                repository: repository),
    'future_set_offline_first_model':
        jsonEncode(instance.futureSetOfflineFirstModel?.toList() ?? []),
    'offline_first_serdes': instance.offlineFirstSerdes?.toSqlite(),
    'list_offline_first_serdes': jsonEncode(instance.listOfflineFirstSerdes
            ?.map((Hat c) => c?.toSqlite())
            ?.toList()
            ?.cast<String>() ??
        []),
    'set_offline_first_serdes': jsonEncode(instance.setOfflineFirstSerdes
            ?.map((Hat c) => c?.toSqlite())
            ?.toList()
            ?.cast<String>() ??
        []),
    'rest_annotation_name': instance.restAnnotationName,
    'rest_annotation_default_value': instance.restAnnotationDefaultValue,
    'rest_annotation_nullable': instance.restAnnotationNullable,
    'rest_annotation_ignore': instance.restAnnotationIgnore,
    'rest_annotation_ignore_to': instance.restAnnotationIgnoreTo,
    'rest_annotation_ignore_from': instance.restAnnotationIgnoreFrom,
    'rest_annotation_from_generator': instance.restAnnotationFromGenerator,
    'rest_annotation_to_generator': instance.restAnnotationToGenerator,
    'enum_from_string': AnyEnum.values.indexOf(instance.enumFromString),
    'sqlite_annotation_nullable': instance.sqliteAnnotationNullable,
    'sqlite_annotation_default_value': instance.sqliteAnnotationDefaultValue,
    'sqlite_annotation_from_generator': instance.sqliteAnnotationFromGenerator,
    'sqlite_annotation_to_generator':
        instance.sqliteAnnotationToGenerator.toString(),
    'sqlite_annotation_unique': instance.sqliteAnnotationUnique,
    'custom column name': instance.sqliteAnnotationName,
    'offline_first_where_Mounty_brick_id':
        instance.offlineFirstWhere?.primaryKey ??
            await provider?.upsert<Mounty>(instance.offlineFirstWhere,
                repository: repository)
  };
}

/// Construct a [KitchenSink]
class KitchenSinkAdapter extends OfflineFirstWithRestAdapter<KitchenSink> {
  KitchenSinkAdapter();

  String restEndpoint({query, instance}) => "/my-path";
  final String fromKey = 'kitchen_sinks';
  final String toKey = 'kitchen_sink';
  final Map<String, Map<String, dynamic>> fieldsToSqliteColumns = {
    'primaryKey': {
      'name': '_brick_id',
      'type': int,
      'iterable': false,
      'association': false,
    },
    'anyString': {
      'name': 'any_string',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'anyInt': {
      'name': 'any_int',
      'type': int,
      'iterable': false,
      'association': false,
    },
    'anyDouble': {
      'name': 'any_double',
      'type': double,
      'iterable': false,
      'association': false,
    },
    'anyNum': {
      'name': 'any_num',
      'type': num,
      'iterable': false,
      'association': false,
    },
    'anyDateTime': {
      'name': 'any_date_time',
      'type': DateTime,
      'iterable': false,
      'association': false,
    },
    'anyBool': {
      'name': 'any_bool',
      'type': bool,
      'iterable': false,
      'association': false,
    },
    'anyMap': {
      'name': 'any_map',
      'type': Map,
      'iterable': false,
      'association': false,
    },
    'enumFromIndex': {
      'name': 'enum_from_index',
      'type': AnyEnum,
      'iterable': false,
      'association': false,
    },
    'anyList': {
      'name': 'any_list',
      'type': int,
      'iterable': true,
      'association': false,
    },
    'anySet': {
      'name': 'any_set',
      'type': int,
      'iterable': true,
      'association': false,
    },
    'offlineFirstModel': {
      'name': 'offline_first_model_Mounty_brick_id',
      'type': Mounty,
      'iterable': false,
      'association': true,
    },
    'listOfflineFirstModel': {
      'name': 'list_offline_first_model',
      'type': Mounty,
      'iterable': true,
      'association': true,
    },
    'setOfflineFirstModel': {
      'name': 'set_offline_first_model',
      'type': Mounty,
      'iterable': true,
      'association': true,
    },
    'futureOfflineFirstModel': {
      'name': 'future_offline_first_model',
      'type': Mounty,
      'iterable': false,
      'association': false,
    },
    'futureListOfflineFirstModel': {
      'name': 'future_list_offline_first_model',
      'type': Mounty,
      'iterable': true,
      'association': true,
    },
    'futureSetOfflineFirstModel': {
      'name': 'future_set_offline_first_model',
      'type': Mounty,
      'iterable': true,
      'association': true,
    },
    'offlineFirstSerdes': {
      'name': 'offline_first_serdes',
      'type': Hat,
      'iterable': false,
      'association': false,
    },
    'listOfflineFirstSerdes': {
      'name': 'list_offline_first_serdes',
      'type': Hat,
      'iterable': true,
      'association': false,
    },
    'setOfflineFirstSerdes': {
      'name': 'set_offline_first_serdes',
      'type': Hat,
      'iterable': true,
      'association': false,
    },
    'restAnnotationName': {
      'name': 'rest_annotation_name',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'restAnnotationDefaultValue': {
      'name': 'rest_annotation_default_value',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'restAnnotationNullable': {
      'name': 'rest_annotation_nullable',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'restAnnotationIgnore': {
      'name': 'rest_annotation_ignore',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'restAnnotationIgnoreTo': {
      'name': 'rest_annotation_ignore_to',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'restAnnotationIgnoreFrom': {
      'name': 'rest_annotation_ignore_from',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'restAnnotationFromGenerator': {
      'name': 'rest_annotation_from_generator',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'restAnnotationToGenerator': {
      'name': 'rest_annotation_to_generator',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'enumFromString': {
      'name': 'enum_from_string',
      'type': AnyEnum,
      'iterable': false,
      'association': false,
    },
    'sqliteAnnotationNullable': {
      'name': 'sqlite_annotation_nullable',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'sqliteAnnotationDefaultValue': {
      'name': 'sqlite_annotation_default_value',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'sqliteAnnotationFromGenerator': {
      'name': 'sqlite_annotation_from_generator',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'sqliteAnnotationToGenerator': {
      'name': 'sqlite_annotation_to_generator',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'sqliteAnnotationUnique': {
      'name': 'sqlite_annotation_unique',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'sqliteAnnotationName': {
      'name': 'custom column name',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'offlineFirstWhere': {
      'name': 'offline_first_where_Mounty_brick_id',
      'type': Mounty,
      'iterable': false,
      'association': true,
    }
  };
  Future<int> primaryKeyByUniqueColumns(
      KitchenSink instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `KitchenSink` WHERE sqlite_annotation_unique = ? LIMIT 1''',
        [instance.sqliteAnnotationUnique]);

    // SQFlite returns [{}] when no results are found
    if (results?.isEmpty == true ||
        (results?.length == 1 && results?.first?.isEmpty == true)) return null;

    return results.first['_brick_id'];
  }

  final String tableName = 'KitchenSink';
  Future<void> afterSave(instance, {provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int>(instance.listOfflineFirstModel?.map((s) async {
        final id = s?.primaryKey ??
            await provider?.upsert<Mounty>(s, repository: repository);
        return await provider?.rawInsert(
            'INSERT OR REPLACE INTO `_brick_KitchenSink_list_offline_first_model` (`KitchenSink_brick_id`, `Mounty_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }

    if (instance.primaryKey != null) {
      await Future.wait<int>(instance.setOfflineFirstModel?.map((s) async {
        final id = s?.primaryKey ??
            await provider?.upsert<Mounty>(s, repository: repository);
        return await provider?.rawInsert(
            'INSERT OR REPLACE INTO `_brick_KitchenSink_set_offline_first_model` (`KitchenSink_brick_id`, `Mounty_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }

    if (instance.primaryKey != null) {
      await Future.wait<int>(
          instance.futureListOfflineFirstModel?.map((s) async {
        final id = (await s)?.primaryKey ??
            await provider?.upsert<Mounty>((await s), repository: repository);
        return await provider?.rawInsert(
            'INSERT OR REPLACE INTO `_brick_KitchenSink_future_list_offline_first_model` (`KitchenSink_brick_id`, `Mounty_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }

    if (instance.primaryKey != null) {
      await Future.wait<int>(
          instance.futureSetOfflineFirstModel?.map((s) async {
        final id = (await s)?.primaryKey ??
            await provider?.upsert<Mounty>((await s), repository: repository);
        return await provider?.rawInsert(
            'INSERT OR REPLACE INTO `_brick_KitchenSink_future_set_offline_first_model` (`KitchenSink_brick_id`, `Mounty_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }
  }

  Future<KitchenSink> fromRest(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$KitchenSinkFromRest(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(KitchenSink input,
          {provider, repository}) async =>
      await _$KitchenSinkToRest(input,
          provider: provider, repository: repository);
  Future<KitchenSink> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$KitchenSinkFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(KitchenSink input,
          {provider, repository}) async =>
      await _$KitchenSinkToSqlite(input,
          provider: provider, repository: repository);
}
