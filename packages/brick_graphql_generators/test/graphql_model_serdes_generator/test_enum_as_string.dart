import 'package:brick_graphql/brick_graphql.dart';

final output = r'''
Future<EnumAsString> _$EnumAsStringFromGraphql(Map<String, dynamic> data,
    {required GraphqlProvider provider,
    GraphqlFirstRepository? repository}) async {
  return EnumAsString(
      hat: Hat.values.byName(data['hat']),
      nullableHat: data['nullableHat'] == null
          ? null
          : Hat.values.byName(data['nullableHat']),
      hats: data['hats']
          .map(Hat.values.byName)
          .toList()
          .cast<Hat>(),
      nullableHats: data['nullableHats']
          .map(Hat.values.byName)
          ?.toList()
          .cast<Hat?>());
}

Future<Map<String, dynamic>> _$EnumAsStringToGraphql(EnumAsString instance,
    {required GraphqlProvider provider,
    GraphqlFirstRepository? repository}) async {
  return {
    'hat': instance.hat.toString().split('.').last,
    'nullableHat': instance.nullableHat?.toString().split('.').last,
    'hats': instance.hats.map((e) => e.toString().split('.').last).toList(),
    'nullableHats':
        instance.nullableHats.map((e) => e.toString().split('.').last).toList()
  };
}
''';

enum Hat { party, dance, sleeping }

/// Output serializing code for all models with the @[GraphqlSerializable] annotation.
/// [GraphqlSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [GraphqlSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@GraphqlSerializable()
class EnumAsString {
  EnumAsString({
    required this.hat,
    this.nullableHat,
    required this.hats,
    required this.nullableHats,
  });

  @Graphql(enumAsString: true)
  final Hat hat;

  @Graphql(enumAsString: true, nullable: true)
  final Hat? nullableHat;

  @Graphql(enumAsString: true)
  final List<Hat> hats;

  @Graphql(enumAsString: true)
  final List<Hat?> nullableHats;
}
