import 'package:brick_rest/rest.dart';

final output = r'''
Future<EnumAsString> _$EnumAsStringFromRest(Map<String, dynamic> data,
    {required RestProvider provider, RestFirstRepository? repository}) async {
  return EnumAsString(
      hat: RestAdapter.enumValueFromName(Hat.values, data['hat'])!,
      nullableHat: data['nullable_hat'] == null
          ? null
          : RestAdapter.enumValueFromName(Hat.values, data['nullable_hat']),
      hats: data['hats']
          .map((value) => RestAdapter.enumValueFromName(Hat.values, value)!)
          .toList()
          .cast<Hat>(),
      nullableHats: data['nullable_hats']
          .map((value) => RestAdapter.enumValueFromName(Hat.values, value))
          ?.toList()
          .cast<Hat?>());
}

Future<Map<String, dynamic>> _$EnumAsStringToRest(EnumAsString instance,
    {required RestProvider provider, RestFirstRepository? repository}) async {
  return {
    'hat': instance.hat.toString().split('.').last,
    'nullable_hat': instance.nullableHat?.toString().split('.').last,
    'hats': instance.hats.map((e) => e.toString().split('.').last).toList(),
    'nullable_hats':
        instance.nullableHats.map((e) => e.toString().split('.').last).toList()
  };
}
''';

enum Hat { party, dance, sleeping }

/// Output serializing code for all models with the @[RestSerializable] annotation.
/// [RestSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [RestSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@RestSerializable()
class EnumAsString {
  EnumAsString({
    required this.hat,
    this.nullableHat,
    required this.hats,
    required this.nullableHats,
  });

  @Rest(enumAsString: true)
  final Hat hat;

  @Rest(enumAsString: true, nullable: true)
  final Hat? nullableHat;

  @Rest(enumAsString: true)
  final List<Hat> hats;

  @Rest(enumAsString: true)
  final List<Hat?> nullableHats;
}
