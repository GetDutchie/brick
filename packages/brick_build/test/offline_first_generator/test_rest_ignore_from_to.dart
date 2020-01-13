import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_rest/rest.dart' show Rest;

final output = r'''
Future<RestIgnoreFromTo> _$RestIgnoreFromToFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return RestIgnoreFromTo(
      ignoredTo: data['ignored_to'] as bool,
      otherIgnoredTo: data['other_ignored_to'] as bool,
      normal: data['normal'] as bool);
}

Future<Map<String, dynamic>> _$RestIgnoreFromToToRest(RestIgnoreFromTo instance,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return {'ignored_from': instance.ignoredFrom, 'normal': instance.normal};
}

Future<RestIgnoreFromTo> _$RestIgnoreFromToFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return RestIgnoreFromTo(
      ignoredFrom:
          data['ignored_from'] == null ? null : data['ignored_from'] == 1,
      ignoredTo: data['ignored_to'] == null ? null : data['ignored_to'] == 1,
      otherIgnoredTo: data['other_ignored_to'] == null
          ? null
          : data['other_ignored_to'] == 1,
      ignorePrecedence: data['ignore_precedence'] == null
          ? null
          : data['ignore_precedence'] == 1,
      normal: data['normal'] == null ? null : data['normal'] == 1)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$RestIgnoreFromToToSqlite(
    RestIgnoreFromTo instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {
    'ignored_from': instance.ignoredFrom,
    'ignored_to': instance.ignoredTo,
    'other_ignored_to': instance.otherIgnoredTo,
    'ignore_precedence': instance.ignorePrecedence,
    'normal': instance.normal
  };
}
''';

@ConnectOfflineFirst()
class RestIgnoreFromTo extends OfflineFirstModel {
  @Rest(ignoreFrom: true)
  final bool ignoredFrom;

  @Rest(ignoreTo: true)
  final bool ignoredTo;

  @Rest(ignoreTo: true, ignoreFrom: false)
  final bool otherIgnoredTo;

  @Rest(ignore: true, ignoreTo: false, ignoreFrom: false)
  final bool ignorePrecedence;

  final bool normal;

  RestIgnoreFromTo(
    this.ignoredFrom,
    this.ignoredTo,
    this.otherIgnoredTo,
    this.ignorePrecedence,
    this.normal,
  );
}
