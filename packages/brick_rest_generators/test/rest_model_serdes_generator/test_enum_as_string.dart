import 'package:brick_rest/rest.dart';

final output = r'''
Future<EnumAsString> _$EnumAsStringFromRest(Map<String, dynamic> data,
    {RestProvider provider, RestFirstRepository repository}) async {
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
    {RestProvider provider, RestFirstRepository repository}) async {
  return {
    'hat': instance.hat?.toString()?.split('.')?.last,
    'hats': instance.hats?.map((e) => e.toString().split('.').last)?.toList()
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
    this.hat,
    this.hats,
  });

  @Rest(enumAsString: true)
  final Hat? hat;

  @Rest(enumAsString: true)
  final List<Hat>? hats;
}
