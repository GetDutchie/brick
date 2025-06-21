import 'package:brick_supabase/brick_supabase.dart';

const output = r'''
Future<EnumAsString> _$EnumAsStringFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return EnumAsString(
    hat: Hat.values.byName(data['hat']),
    nullableHat: data['nullable_hat'] == null
        ? null
        : Hat.values.byName(data['nullable_hat']),
    hats: data['hats']
        .whereType<String>()
        .map(Hat.values.byName)
        .toList()
        .cast<Hat>(),
    nullableHats: data['nullable_hats']
        .whereType<String>()
        .map(Hat.values.byName)
        ?.toList()
        .cast<Hat?>(),
  );
}

Future<Map<String, dynamic>> _$EnumAsStringToSupabase(
  EnumAsString instance, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return {
    'hat': instance.hat.name,
    'nullable_hat': instance.nullableHat?.name,
    'hats': instance.hats.map((e) => e.name).toList(),
    'nullable_hats': instance.nullableHats.map((e) => e.name).toList(),
  };
}
''';

enum Hat { party, dance, sleeping }

/// Output serializing code for all models with the @[SupabaseSerializable] annotation.
/// [SupabaseSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SupabaseSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SupabaseSerializable()
class EnumAsString {
  EnumAsString({
    required this.hat,
    this.nullableHat,
    required this.hats,
    required this.nullableHats,
  });

  @Supabase(enumAsString: true)
  final Hat hat;

  @Supabase(enumAsString: true)
  final Hat? nullableHat;

  @Supabase(enumAsString: true)
  final List<Hat> hats;

  @Supabase(enumAsString: true)
  final List<Hat?> nullableHats;
}
