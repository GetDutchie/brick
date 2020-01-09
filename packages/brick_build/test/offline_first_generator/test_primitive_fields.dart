import 'package:brick_offline_first_abstract/annotations.dart';

enum Casing { snake, camel }

final output = r'''
Future<PrimitiveFields> _$PrimitiveFieldsFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return PrimitiveFields(
      integer: data['integer'] as int,
      boolean: data['boolean'] as bool,
      dub: data['dub'] as double,
      string: data['string'] as String,
      list: data['list']?.toList()?.cast<int>() ?? List<int>(),
      aSet: data['a_set']?.toSet()?.cast<int>() ?? Set<int>(),
      map: data['map'],
      longerCamelizedVariable: data['longer_camelized_variable'] as String,
      casing:
          data['casing'] is int ? Casing.values[data['casing'] as int] : null,
      dateTime: data['date_time'] == null
          ? null
          : DateTime.tryParse(data['date_time'] as String));
}

Future<Map<String, dynamic>> _$PrimitiveFieldsToRest(PrimitiveFields instance,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return {
    'integer': instance.integer,
    'boolean': instance.boolean,
    'dub': instance.dub,
    'string': instance.string,
    'list': instance.list,
    'a_set': instance.aSet,
    'map': instance.map,
    'longer_camelized_variable': instance.longerCamelizedVariable,
    'casing':
        instance.casing != null ? Casing.values.indexOf(instance.casing) : null,
    'date_time': instance.dateTime?.toIso8601String()
  };
}

Future<PrimitiveFields> _$PrimitiveFieldsFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return PrimitiveFields(
      integer: data['integer'] == null ? null : data['integer'] as int,
      boolean: data['boolean'] == null ? null : data['boolean'] == 1,
      dub: data['dub'] == null ? null : data['dub'] as double,
      string: data['string'] == null ? null : data['string'] as String,
      list: data['list'] == null
          ? null
          : jsonDecode(data['list'])?.toList()?.cast<int>(),
      aSet: data['a_set'] == null
          ? null
          : jsonDecode(data['a_set'])?.toSet()?.cast<int>(),
      map: data['map'] == null ? null : jsonDecode(data['map']),
      longerCamelizedVariable: data['longer_camelized_variable'] == null
          ? null
          : data['longer_camelized_variable'] as String,
      casing: data['casing'] == null
          ? null
          : (data['casing'] > -1 ? Casing.values[data['casing'] as int] : null),
      dateTime: data['date_time'] == null
          ? null
          : data['date_time'] == null
              ? null
              : DateTime.tryParse(data['date_time'] as String))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$PrimitiveFieldsToSqlite(PrimitiveFields instance,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return {
    'integer': instance.integer,
    'boolean': instance.boolean,
    'dub': instance.dub,
    'string': instance.string,
    'list': jsonEncode(instance.list ?? []),
    'a_set': jsonEncode(instance.aSet ?? []),
    'map': jsonEncode(instance.map ?? {}),
    'longer_camelized_variable': instance.longerCamelizedVariable,
    'casing': Casing.values.indexOf(instance.casing),
    'date_time': instance.dateTime?.toIso8601String()
  };
}
''';

@ConnectOfflineFirst()
class PrimitiveFields {
  PrimitiveFields({
    this.integer,
    this.boolean,
    this.dub,
    this.string,
    this.list,
    this.aSet,
    this.map,
    this.longerCamelizedVariable,
    this.casing,
    this.dateTime,
  });

  final int integer;
  final bool boolean;
  final double dub;
  final String string;
  final List<int> list;
  final Set<int> aSet;
  final Map<String, dynamic> map;
  final String longerCamelizedVariable;
  final Casing casing;
  final DateTime dateTime;
}
