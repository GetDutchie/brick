import 'dart:io';
import 'dart:typed_data';

import 'package:brick_graphql/brick_graphql.dart';

const output = r'''
Future<GraphqlUnserializableFieldWithGenerator>
_$GraphqlUnserializableFieldWithGeneratorFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return GraphqlUnserializableFieldWithGenerator(withFrom: data['withFrom']);
}

Future<Map<String, dynamic>> _$GraphqlUnserializableFieldWithGeneratorToGraphql(
  GraphqlUnserializableFieldWithGenerator instance, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return {'withTo': instance.withTo};
}
''';

/// Output serializing code for all models with the @[GraphqlSerializable] annotation.
/// [GraphqlSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [GraphqlSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@GraphqlSerializable()
class GraphqlUnserializableFieldWithGenerator extends GraphqlModel {
  @Graphql(fromGenerator: '%DATA_PROPERTY%')
  final File withFrom;

  @Graphql(toGenerator: '%INSTANCE_PROPERTY%')
  final Uint8List withTo;

  GraphqlUnserializableFieldWithGenerator(
    this.withFrom,
    this.withTo,
  );
}
