import 'dart:io';
import 'dart:typed_data';

import 'package:brick_rest/brick_rest.dart';

const output = r'''
Future<RestUnserializableFieldWithGenerator>
_$RestUnserializableFieldWithGeneratorFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  RestFirstRepository? repository,
}) async {
  return RestUnserializableFieldWithGenerator(withFrom: data['with_from']);
}

Future<Map<String, dynamic>> _$RestUnserializableFieldWithGeneratorToRest(
  RestUnserializableFieldWithGenerator instance, {
  required RestProvider provider,
  RestFirstRepository? repository,
}) async {
  return {'with_to': instance.withTo};
}
''';

/// Output serializing code for all models with the @[RestSerializable] annotation.
/// [RestSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [RestSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@RestSerializable()
class RestUnserializableFieldWithGenerator extends RestModel {
  @Rest(fromGenerator: '%DATA_PROPERTY%')
  final File withFrom;

  @Rest(toGenerator: '%INSTANCE_PROPERTY%')
  final Uint8List withTo;

  RestUnserializableFieldWithGenerator(
    this.withFrom,
    this.withTo,
  );
}
