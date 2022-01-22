import 'package:brick_graphql/graphql.dart';

final output = r'''
Future<EnumAsString> _$EnumAsStringFromGraphQL(Map<String, dynamic> data,
    {required GraphQLProvider provider,
    GraphqlFirstRepository? repository}) async {
  return EnumAsString(
      hat: GraphqlAdapter.enumValueFromName(Hat.values, data['hat'])!,
      nullableHat: data['nullableHat'] == null
          ? null
          : GraphqlAdapter.enumValueFromName(Hat.values, data['nullableHat']),
      hats: data['hats']
          .map((value) => GraphqlAdapter.enumValueFromName(Hat.values, value)!)
          .toList()
          .cast<Hat>(),
      nullableHats: data['nullableHats']
          .map((value) => GraphqlAdapter.enumValueFromName(Hat.values, value))
          ?.toList()
          .cast<Hat?>());
}

Future<Map<String, dynamic>> _$EnumAsStringToGraphQL(EnumAsString instance,
    {required GraphQLProvider provider,
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
