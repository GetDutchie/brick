import 'dart:typed_data';
import 'dart:io';

import 'package:brick_graphql/graphql.dart';

final output = r'''
Future<GraphQLUnserializableFieldWithGenerator>
    _$GraphQLUnserializableFieldWithGeneratorFromGraphQL(
        Map<String, dynamic> data,
        {required GraphQLProvider provider,
        GraphQLFirstRepository? repository}) async {
  return GraphQLUnserializableFieldWithGenerator(withFrom: data['withFrom']);
}

Future<Map<String, dynamic>> _$GraphQLUnserializableFieldWithGeneratorToGraphQL(
    GraphQLUnserializableFieldWithGenerator instance,
    {required GraphQLProvider provider,
    GraphQLFirstRepository? repository}) async {
  return {'withTo': instance.withTo};
}
''';

/// Output serializing code for all models with the @[GraphqlSerializable] annotation.
/// [GraphqlSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [GraphqlSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@GraphqlSerializable()
class GraphQLUnserializableFieldWithGenerator extends GraphqlModel {
  @GraphQL(fromGenerator: '%DATA_PROPERTY%')
  final File withFrom;

  @GraphQL(toGenerator: '%INSTANCE_PROPERTY%')
  final Uint8List withTo;

  GraphQLUnserializableFieldWithGenerator(
    this.withFrom,
    this.withTo,
  );
}
