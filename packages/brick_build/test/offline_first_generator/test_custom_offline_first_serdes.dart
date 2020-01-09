import 'package:brick_offline_first_abstract/abstract.dart' show OfflineFirstSerdes;
import 'package:brick_offline_first_abstract/annotations.dart';

final output = r'''
Future<CustomOfflineFirstSerdes> _$CustomOfflineFirstSerdesFromRest(
    Map<String, dynamic> data,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return CustomOfflineFirstSerdes(
      string: Serializable.fromRest(data['string']),
      strings: data['strings']
          .map((c) => Serializable.fromRest(c as Map))
          ?.toList()
          ?.cast<Serializable>());
}

Future<Map<String, dynamic>> _$CustomOfflineFirstSerdesToRest(
    CustomOfflineFirstSerdes instance,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return {
    'string': instance.string?.toRest(),
    'strings': instance.strings?.map((Serializable c) => c?.toRest())
  };
}

Future<CustomOfflineFirstSerdes> _$CustomOfflineFirstSerdesFromSqlite(
    Map<String, dynamic> data,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return CustomOfflineFirstSerdes(
      string: data['string'] == null
          ? null
          : Serializable.fromSqlite(data['string'] as int),
      strings: data['strings'] == null
          ? null
          : jsonDecode(data['strings'])
              .map((c) => Serializable.fromSqlite(c as int))
              ?.toList()
              ?.cast<Serializable>())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CustomOfflineFirstSerdesToSqlite(
    CustomOfflineFirstSerdes instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {};
}
''';

class Serializable extends OfflineFirstSerdes<Map<String, dynamic>, int> {
  final int age;
  Serializable(this.age);
  toRest() => {'age': '$age'};

  factory Serializable.fromRest(Map<String, dynamic> data) {
    return Serializable(data['age']);
  }

  factory Serializable.fromSqlite(age) {
    return Serializable(age);
  }
}

@ConnectOfflineFirst()
class CustomOfflineFirstSerdes {
  CustomOfflineFirstSerdes({this.string, this.strings});

  final Serializable string;

  final List<Serializable> strings;
}
