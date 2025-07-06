import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';

enum Casing { snake, camel }

const output = r'''
Future<PrimitiveFields> _$PrimitiveFieldsFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return PrimitiveFields(
    nullableInteger: data['nullable_integer'] == null
        ? null
        : data['nullable_integer'] as int?,
    nullableBoolean: data['nullable_boolean'] == null
        ? null
        : data['nullable_boolean'] as bool?,
    nullableDub: data['nullable_dub'] == null
        ? null
        : data['nullable_dub'] as double?,
    nullableString: data['nullable_string'] == null
        ? null
        : data['nullable_string'] as String?,
    nullableList: data['nullable_list'] == null
        ? null
        : data['nullable_list']?.toList().cast<int>(),
    nullableSet: data['nullable_set'] == null
        ? null
        : data['nullable_set']?.toSet().cast<int>(),
    nullableMap: data['nullable_map'] == null ? null : data['nullable_map'],
    nullableLongerCamelizedVariable:
        data['nullable_longer_camelized_variable'] == null
        ? null
        : data['nullable_longer_camelized_variable'] as String?,
    nullableCasing: data['nullable_casing'] == null
        ? null
        : data['nullable_casing'] is int
        ? Casing.values[data['nullable_casing'] as int]
        : null,
    nullableListCasing: data['nullable_list_casing'] == null
        ? null
        : data['nullable_list_casing']
              .map((e) => Casing.values[e])
              .toList()
              .cast<Casing>(),
    nullableDateTime: data['nullable_date_time'] == null
        ? null
        : data['nullable_date_time'] == null
        ? null
        : DateTime.tryParse(data['nullable_date_time'] as String),
    integer: data['integer'] as int,
    boolean: data['boolean'] as bool,
    dub: data['dub'] as double,
    string: data['string'] as String,
    list: data['list'].toList().cast<int>(),
    aSet: data['a_set'].toSet().cast<int>(),
    map: data['map'],
    longerCamelizedVariable: data['longer_camelized_variable'] as String,
    casing: Casing.values[data['casing'] as int],
    listCasing: data['list_casing']
        .map((e) => Casing.values[e])
        .toList()
        .cast<Casing>(),
    dateTime: DateTime.parse(data['date_time'] as String),
  );
}

Future<Map<String, dynamic>> _$PrimitiveFieldsToTest(
  PrimitiveFields instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'nullable_integer': instance.nullableInteger,
    'nullable_boolean': instance.nullableBoolean,
    'nullable_dub': instance.nullableDub,
    'nullable_string': instance.nullableString,
    'nullable_list': instance.nullableList,
    'nullable_set': instance.nullableSet,
    'nullable_map': instance.nullableMap,
    'nullable_longer_camelized_variable':
        instance.nullableLongerCamelizedVariable,
    'nullable_casing': instance.nullableCasing != null
        ? Casing.values.indexOf(instance.nullableCasing!)
        : null,
    'nullable_list_casing': instance.nullableListCasing
        ?.map((e) => Casing.values.indexOf(e))
        .toList(),
    'nullable_date_time': instance.nullableDateTime?.toIso8601String(),
    'integer': instance.integer,
    'boolean': instance.boolean,
    'dub': instance.dub,
    'string': instance.string,
    'list': instance.list,
    'a_set': instance.aSet,
    'map': instance.map,
    'longer_camelized_variable': instance.longerCamelizedVariable,
    'casing': Casing.values.indexOf(instance.casing),
    'list_casing': instance.listCasing
        .map((e) => Casing.values.indexOf(e))
        .toList(),
    'date_time': instance.dateTime.toIso8601String(),
  };
}

Future<PrimitiveFields> _$PrimitiveFieldsFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return PrimitiveFields(
    nullableInteger: data['nullable_integer'] == null
        ? null
        : data['nullable_integer'] as int?,
    nullableBoolean: data['nullable_boolean'] == null
        ? null
        : data['nullable_boolean'] == 1,
    nullableDub: data['nullable_dub'] == null
        ? null
        : data['nullable_dub'] as double?,
    nullableString: data['nullable_string'] == null
        ? null
        : data['nullable_string'] as String?,
    nullableList: data['nullable_list'] == null
        ? null
        : jsonDecode(data['nullable_list']).toList().cast<int>(),
    nullableSet: data['nullable_set'] == null
        ? null
        : jsonDecode(data['nullable_set']).toSet().cast<int>(),
    nullableMap: data['nullable_map'] == null
        ? null
        : jsonDecode(data['nullable_map']),
    nullableLongerCamelizedVariable:
        data['nullable_longer_camelized_variable'] == null
        ? null
        : data['nullable_longer_camelized_variable'] as String?,
    nullableCasing: data['nullable_casing'] == null
        ? null
        : (data['nullable_casing'] > -1
              ? Casing.values[data['nullable_casing'] as int]
              : null),
    nullableListCasing: data['nullable_list_casing'] == null
        ? null
        : jsonDecode(data['nullable_list_casing'])
              .map((d) => d as int > -1 ? Casing.values[d] : null)
              ?.whereType<Casing>()
              .toList()
              .cast<Casing>(),
    nullableDateTime: data['nullable_date_time'] == null
        ? null
        : data['nullable_date_time'] == null
        ? null
        : DateTime.tryParse(data['nullable_date_time'] as String),
    integer: data['integer'] as int,
    boolean: data['boolean'] == 1,
    dub: data['dub'] as double,
    string: data['string'] as String,
    list: jsonDecode(data['list']).toList().cast<int>(),
    aSet: jsonDecode(data['a_set']).toSet().cast<int>(),
    map: jsonDecode(data['map']),
    longerCamelizedVariable: data['longer_camelized_variable'] as String,
    casing: Casing.values[data['casing'] as int],
    listCasing: jsonDecode(data['list_casing'])
        .map((d) => d as int > -1 ? Casing.values[d] : null)
        .whereType<Casing>()
        .toList()
        .cast<Casing>(),
    dateTime: DateTime.parse(data['date_time'] as String),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$PrimitiveFieldsToSqlite(
  PrimitiveFields instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'nullable_integer': instance.nullableInteger,
    'nullable_boolean': instance.nullableBoolean == null
        ? null
        : (instance.nullableBoolean! ? 1 : 0),
    'nullable_dub': instance.nullableDub,
    'nullable_string': instance.nullableString,
    'nullable_list': instance.nullableList == null
        ? null
        : jsonEncode(instance.nullableList),
    'nullable_set': instance.nullableSet == null
        ? null
        : jsonEncode(instance.nullableSet.toList()),
    'nullable_map': instance.nullableMap != null
        ? jsonEncode(instance.nullableMap)
        : null,
    'nullable_longer_camelized_variable':
        instance.nullableLongerCamelizedVariable,
    'nullable_casing': instance.nullableCasing != null
        ? Casing.values.indexOf(instance.nullableCasing!)
        : null,
    'nullable_list_casing': jsonEncode(
      instance.nullableListCasing
              ?.map((s) => Casing.values.indexOf(s))
              .toList() ??
          [],
    ),
    'nullable_date_time': instance.nullableDateTime?.toIso8601String(),
    'integer': instance.integer,
    'boolean': instance.boolean ? 1 : 0,
    'dub': instance.dub,
    'string': instance.string,
    'list': jsonEncode(instance.list),
    'a_set': jsonEncode(instance.aSet.toList()),
    'map': jsonEncode(instance.map),
    'longer_camelized_variable': instance.longerCamelizedVariable,
    'casing': Casing.values.indexOf(instance.casing),
    'list_casing': jsonEncode(
      instance.listCasing.map((s) => Casing.values.indexOf(s)).toList(),
    ),
    'date_time': instance.dateTime.toIso8601String(),
  };
}
''';

@ConnectOfflineFirstWithRest()
class PrimitiveFields {
  PrimitiveFields({
    this.nullableInteger,
    this.nullableBoolean,
    this.nullableDub,
    this.nullableString,
    this.nullableList,
    this.nullableSet,
    this.nullableMap,
    this.nullableLongerCamelizedVariable,
    this.nullableCasing,
    this.nullableListCasing,
    this.nullableDateTime,
    required this.integer,
    required this.boolean,
    required this.dub,
    required this.string,
    required this.list,
    required this.aSet,
    required this.map,
    required this.longerCamelizedVariable,
    required this.casing,
    required this.listCasing,
    required this.dateTime,
  });

  final int? nullableInteger;
  final bool? nullableBoolean;
  final double? nullableDub;
  final String? nullableString;
  final List<int>? nullableList;
  final Set<int>? nullableSet;
  final Map<String, dynamic>? nullableMap;
  final String? nullableLongerCamelizedVariable;
  final Casing? nullableCasing;
  final List<Casing>? nullableListCasing;
  final DateTime? nullableDateTime;

  final int integer;
  final bool boolean;
  final double dub;
  final String string;
  final List<int> list;
  final Set<int> aSet;
  final Map<String, dynamic> map;
  final String longerCamelizedVariable;
  final Casing casing;
  final List<Casing> listCasing;
  final DateTime dateTime;
}
