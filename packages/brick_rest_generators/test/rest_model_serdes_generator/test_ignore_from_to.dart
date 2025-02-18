import 'package:brick_rest/brick_rest.dart';

const output = r'''
Future<RestIgnoreFromTo> _$RestIgnoreFromToFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  RestFirstRepository? repository,
}) async {
  return RestIgnoreFromTo(
    ignoredTo: data['ignored_to'] as bool,
    otherIgnoredTo: data['other_ignored_to'] as bool,
    normal: data['normal'] as bool,
  );
}

Future<Map<String, dynamic>> _$RestIgnoreFromToToRest(
  RestIgnoreFromTo instance, {
  required RestProvider provider,
  RestFirstRepository? repository,
}) async {
  return {'ignored_from': instance.ignoredFrom, 'normal': instance.normal};
}
''';

/// Output serializing code for all models with the @[RestSerializable] annotation.
/// [RestSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [RestSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@RestSerializable()
class RestIgnoreFromTo extends RestModel {
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
