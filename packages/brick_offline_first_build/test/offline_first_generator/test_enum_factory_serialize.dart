import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';

const output = r'''
Future<EnumFactorySerialize> _$EnumFactorySerializeFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return EnumFactorySerialize(
    withFactory: WithFactory.fromTest(data['with_factory']),
    withSerialize: WithSerializeMethod.values[data['with_serialize'] as int],
    withBoth: WithBoth.fromTest(data['with_both']),
    withBothIterable: data['with_both_iterable'].map(WithBoth.fromTest),
    withBothNullable: data['with_both_nullable'] == null
        ? null
        : WithBoth.fromTest(data['with_both_nullable']),
    withJson: WithJson.values[data['with_json'] as int],
  );
}

Future<Map<String, dynamic>> _$EnumFactorySerializeToTest(
  EnumFactorySerialize instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'with_factory': WithFactory.values.indexOf(instance.withFactory),
    'with_serialize': instance.withSerialize.toTest(),
    'with_both': instance.withBoth.toTest(),
    'with_both_iterable': instance.withBothIterable
        .map((e) => e.toTest())
        .toList(),
    'with_both_nullable': instance.withBothNullable?.toTest(),
    'with_json': instance.withJson.toTest(),
  };
}

Future<EnumFactorySerialize> _$EnumFactorySerializeFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return EnumFactorySerialize(
    withFactory: WithFactory.values[data['with_factory'] as int],
    withSerialize: WithSerializeMethod.values[data['with_serialize'] as int],
    withBoth: WithBoth.values[data['with_both'] as int],
    withBothIterable: jsonDecode(data['with_both_iterable'])
        .map((d) => d as int > -1 ? WithBoth.values[d] : null)
        .whereType<WithBoth>()
        .toList()
        .cast<WithBoth>(),
    withBothNullable: data['with_both_nullable'] == null
        ? null
        : (data['with_both_nullable'] > -1
              ? WithBoth.values[data['with_both_nullable'] as int]
              : null),
    withJson: WithJson.values[data['with_json'] as int],
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$EnumFactorySerializeToSqlite(
  EnumFactorySerialize instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'with_factory': WithFactory.values.indexOf(instance.withFactory),
    'with_serialize': WithSerializeMethod.values.indexOf(
      instance.withSerialize,
    ),
    'with_both': WithBoth.values.indexOf(instance.withBoth),
    'with_both_iterable': jsonEncode(
      instance.withBothIterable.map((s) => WithBoth.values.indexOf(s)).toList(),
    ),
    'with_both_nullable': instance.withBothNullable != null
        ? WithBoth.values.indexOf(instance.withBothNullable!)
        : null,
    'with_json': instance.withJson.toJson(),
  };
}
''';

enum WithFactory {
  a,
  b;

  factory WithFactory.fromTest(String data) => data == a.name ? a : b;
}

enum WithSerializeMethod {
  a,
  b;

  String toTest() => name;
}

enum WithBoth {
  a,
  b;

  factory WithBoth.fromTest(String data) => data == a.name ? a : b;

  String toTest() => name;
}

enum WithJson {
  a,
  b;

  String toTest() => name;

  String toJson() => name;
}

@ConnectOfflineFirstWithRest()
class EnumFactorySerialize {
  final WithFactory withFactory;

  final WithSerializeMethod withSerialize;

  final WithBoth withBoth;

  final List<WithBoth> withBothIterable;

  final WithBoth? withBothNullable;

  final WithJson withJson;

  EnumFactorySerialize(
    this.withFactory,
    this.withSerialize,
    this.withBoth,
    this.withBothIterable,
    this.withBothNullable,
    this.withJson,
  );
}
