import 'package:brick_graphql/brick_graphql.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<ToFromJson> _$ToFromJsonFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return ToFromJson(assoc: ToFromJsonAssoc.fromJson(data['assoc'] as String));
}

Future<Map<String, dynamic>> _$ToFromJsonToGraphql(
  ToFromJson instance, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return {'assoc': instance.assoc.toJson()};
}

/// Construct a [ToFromJson]
class ToFromJsonAdapter extends GraphqlFirstAdapter<ToFromJson> {
  ToFromJsonAdapter();

  @override
  final fieldsToGraphqlRuntimeDefinition = <String, RuntimeGraphqlDefinition>{
    'assoc': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'assoc',
      iterable: false,
      subfields: <String, Map<String, dynamic>>{
        'subfield1': {},
        'subfield2': {'nestedSubfield': {}},
      },
      type: Map,
    ),
  };

  @override
  Future<ToFromJson> fromGraphql(
    Map<String, dynamic> input, {
    required provider,
    covariant GraphqlFirstRepository? repository,
  }) async => await _$ToFromJsonFromGraphql(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toGraphql(
    ToFromJson input, {
    required provider,
    covariant GraphqlFirstRepository? repository,
  }) async => await _$ToFromJsonToGraphql(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

class ToFromJsonAssoc {
  final int? integer;

  ToFromJsonAssoc({
    this.integer,
  });

  Map<String, int?> toJson() => {'integer': integer};

  factory ToFromJsonAssoc.fromJson(String data) => ToFromJsonAssoc(integer: int.tryParse(data));
}

@GraphqlSerializable()
class ToFromJson {
  @Graphql(
    subfields: {
      'subfield1': {},
      'subfield2': {
        'nestedSubfield': {},
      },
    },
  )
  final ToFromJsonAssoc assoc;

  ToFromJson({
    required this.assoc,
  });
}
