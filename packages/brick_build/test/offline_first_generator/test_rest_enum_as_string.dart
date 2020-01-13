import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_rest/rest.dart' show Rest;

final output = r'''
Future<EnumAsString> _$EnumAsStringFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return EnumAsString(
      hat: Hat.values.firstWhere(
          (h) => h.toString().split('.').last == data['hat'],
          orElse: () => null),
      hats: data['hats']
          .map((value) => Hat.values.firstWhere(
              (e) => e.toString().split('.').last == value,
              orElse: () => null))
          ?.toList()
          ?.cast<Hat>());
}

Future<Map<String, dynamic>> _$EnumAsStringToRest(EnumAsString instance,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return {
    'hat': instance.hat?.toString()?.split('.')?.last,
    'hats': instance.hats?.map((e) => e.toString().split('.').last)
  };
}

Future<EnumAsString> _$EnumAsStringFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return EnumAsString(
      hat: data['hat'] == null
          ? null
          : (data['hat'] > -1 ? Hat.values[data['hat'] as int] : null),
      hats: data['hats'] == null
          ? null
          : jsonDecode(data['hats'])
              .map((d) => d as int > -1 ? Hat.values[d as int] : null)
              ?.toList()
              ?.cast<Hat>())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$EnumAsStringToSqlite(EnumAsString instance,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return {
    'hat': Hat.values.indexOf(instance.hat),
    'hats': jsonEncode(instance.hats
            ?.map((s) => Hat.values.indexOf(s))
            ?.toList()
            ?.cast<int>() ??
        [])
  };
}
''';

enum Hat { party, dance, sleeping }

@ConnectOfflineFirst()
class EnumAsString {
  EnumAsString({
    this.hat,
    this.hats,
  });

  @Rest(enumAsString: true)
  final Hat hat;

  @Rest(enumAsString: true)
  final List<Hat> hats;
}
