import 'package:brick_supabase/brick_supabase.dart';

const output = r'''
Future<SupabaseIgnoreFromTo> _$SupabaseIgnoreFromToFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return SupabaseIgnoreFromTo(
    ignoredTo: data['ignored_to'] as bool,
    otherIgnoredTo: data['other_ignored_to'] as bool,
    normal: data['normal'] as bool,
  );
}

Future<Map<String, dynamic>> _$SupabaseIgnoreFromToToSupabase(
  SupabaseIgnoreFromTo instance, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return {'ignored_from': instance.ignoredFrom, 'normal': instance.normal};
}
''';

/// Output serializing code for all models with the @[SupabaseSerializable] annotation.
/// [SupabaseSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SupabaseSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SupabaseSerializable()
class SupabaseIgnoreFromTo extends SupabaseModel {
  @Supabase(ignoreFrom: true)
  final bool ignoredFrom;

  @Supabase(ignoreTo: true)
  final bool ignoredTo;

  @Supabase(ignoreTo: true, ignoreFrom: false)
  final bool otherIgnoredTo;

  @Supabase(ignore: true, ignoreTo: false, ignoreFrom: false)
  final bool ignorePrecedence;

  final bool normal;

  SupabaseIgnoreFromTo(
    this.ignoredFrom,
    this.ignoredTo,
    this.otherIgnoredTo,
    this.ignorePrecedence,
    this.normal,
  );
}
