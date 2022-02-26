import 'package:brick_graphql/graphql.dart';

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<ToFromJson> _$ToFromJsonFromGraphql(Map<String, dynamic> data,
    {required GraphqlProvider provider,
    GraphqlFirstRepository? repository}) async {
  return ToFromJson(
      assoc: ToFromJsonAssoc.fromJson(data['assoc'] as String),
      assocNullable: data['assocNullable'] != null
          ? ToFromJsonAssoc.fromJson(data['assocNullable'] as String)
          : null,
      assocIterable: data['assocIterable']
          .map((d) => ToFromJsonAssoc.fromJson(d as String))
          .toList()
          .cast<ToFromJsonAssoc>(),
      assocIterableNullable: data['assocIterableNullable']
          ?.map((d) => ToFromJsonAssoc.fromJson(d as String))
          .toList()
          .cast<ToFromJsonAssoc>());
}

Future<Map<String, dynamic>> _$ToFromJsonToGraphql(ToFromJson instance,
    {required GraphqlProvider provider,
    GraphqlFirstRepository? repository}) async {
  return {
    'assoc': instance.assoc.toJson(),
    'assocNullable': instance.assocNullable?.toJson(),
    'assocIterable': instance.assocIterable.map((s) => s.toJson()).toList(),
    'assocIterableNullable':
        instance.assocIterableNullable?.map((s) => s.toJson()).toList()
  };
}

/// Construct a [ToFromJson]
class ToFromJsonAdapter extends GraphqlFirstAdapter<ToFromJson> {
  ToFromJsonAdapter();

  @override
  final Map<String, RuntimeGraphqlDefinition> fieldsToGraphqlRuntimeDefinition =
      {
    'assoc': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'assoc',
      iterable: false,
      subfields: {integer},
      type: String,
    ),
    'assocNullable': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'assocNullable',
      iterable: false,
      subfields: {integer},
      type: String,
    ),
    'assocIterable': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'assocIterable',
      iterable: true,
      subfields: {integer},
      type: String,
    ),
    'assocIterableNullable': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'assocIterableNullable',
      iterable: true,
      subfields: {integer},
      type: String,
    )
  };

  @override
  Future<ToFromJson> fromGraphql(Map<String, dynamic> input,
          {required provider,
          covariant GraphqlFirstRepository? repository}) async =>
      await _$ToFromJsonFromGraphql(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(ToFromJson input,
          {required provider,
          covariant GraphqlFirstRepository? repository}) async =>
      await _$ToFromJsonToGraphql(input,
          provider: provider, repository: repository);
}
''';

class ToFromJsonAssoc {
  final int? integer;

  ToFromJsonAssoc({
    this.integer,
  });

  String toJson() => integer.toString();

  factory ToFromJsonAssoc.fromJson(String data) => ToFromJsonAssoc(integer: int.tryParse(data));
}

@GraphqlSerializable()
class ToFromJson {
  final ToFromJsonAssoc assoc;
  final ToFromJsonAssoc? assocNullable;
  final List<ToFromJsonAssoc> assocIterable;
  final List<ToFromJsonAssoc>? assocIterableNullable;

  ToFromJson({
    required this.assoc,
    required this.assocNullable,
    required this.assocIterable,
    required this.assocIterableNullable,
  });
}
