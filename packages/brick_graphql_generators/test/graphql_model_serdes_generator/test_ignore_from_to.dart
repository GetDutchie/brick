import 'package:brick_graphql/brick_graphql.dart';

const output = r'''
Future<GraphqlIgnoreFromTo> _$GraphqlIgnoreFromToFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return GraphqlIgnoreFromTo(
    ignoredTo: data['ignoredTo'] as bool,
    otherIgnoredTo: data['otherIgnoredTo'] as bool,
    normal: data['normal'] as bool,
  );
}

Future<Map<String, dynamic>> _$GraphqlIgnoreFromToToGraphql(
  GraphqlIgnoreFromTo instance, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return {'ignoredFrom': instance.ignoredFrom, 'normal': instance.normal};
}
''';

/// Output serializing code for all models with the @[GraphqlSerializable] annotation.
/// [GraphqlSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [GraphqlSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@GraphqlSerializable()
class GraphqlIgnoreFromTo extends GraphqlModel {
  @Graphql(ignoreFrom: true)
  final bool ignoredFrom;

  @Graphql(ignoreTo: true)
  final bool ignoredTo;

  @Graphql(ignoreTo: true, ignoreFrom: false)
  final bool otherIgnoredTo;

  @Graphql(ignore: true, ignoreTo: false, ignoreFrom: false)
  final bool ignorePrecedence;

  final bool normal;

  GraphqlIgnoreFromTo(
    this.ignoredFrom,
    this.ignoredTo,
    this.otherIgnoredTo,
    this.ignorePrecedence,
    this.normal,
  );
}
