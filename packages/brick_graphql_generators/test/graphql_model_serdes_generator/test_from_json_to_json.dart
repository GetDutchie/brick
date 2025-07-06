import 'package:brick_graphql/brick_graphql.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<ToFromJson> _$ToFromJsonFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return ToFromJson(
    assoc: ToFromJsonAssoc.fromJson(data['assoc'] as String),
    assocNullable: data['assocNullable'] == null
        ? null
        : ToFromJsonAssoc.fromJson(data['assocNullable'] as String),
    assocIterable: data['assocIterable']
        .map((d) => ToFromJsonAssoc.fromJson(d as String))
        .toList()
        .cast<ToFromJsonAssoc>(),
    assocIterableNullable: data['assocIterableNullable'] == null
        ? null
        : data['assocIterableNullable']
              ?.map((d) => ToFromJsonAssoc.fromJson(d as String))
              .toList()
              .cast<ToFromJsonAssoc>(),
  );
}

Future<Map<String, dynamic>> _$ToFromJsonToGraphql(
  ToFromJson instance, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return {
    'assoc': instance.assoc.toJson(),
    'assocNullable': instance.assocNullable?.toJson(),
    'assocIterable': instance.assocIterable.map((s) => s.toJson()).toList(),
    'assocIterableNullable': instance.assocIterableNullable
        ?.map((s) => s.toJson())
        .toList(),
  };
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
        'integer': {},
        'sub': {'prop': {}, 'subProp': {}},
      },
      type: Map,
    ),
    'assocNullable': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'assocNullable',
      iterable: false,
      subfields: <String, Map<String, dynamic>>{
        'integer': {},
        'sub': {'prop': {}, 'subProp': {}},
      },
      type: Map,
    ),
    'assocIterable': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'assocIterable',
      iterable: true,
      subfields: <String, Map<String, dynamic>>{
        'integer': {},
        'sub': {'prop': {}, 'subProp': {}},
      },
      type: Map,
    ),
    'assocIterableNullable': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'assocIterableNullable',
      iterable: true,
      subfields: <String, Map<String, dynamic>>{
        'integer': {},
        'sub': {'prop': {}, 'subProp': {}},
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

class SubClass {
  final String prop;
  final int? subProp;

  SubClass({
    required this.prop,
    required this.subProp,
  });

  factory SubClass.fromJson(Map<String, dynamic> data) => SubClass(
        prop: data['prop'],
        subProp: int.tryParse(data['subProp']),
      );

  Map<String, dynamic> toJson() => {'prop': prop, 'subProp': subProp};
}

class ToFromJsonAssoc {
  String get ignoreComputedGetter => integer.toString();

  String? ignoreNonFinal;

  final int? integer;

  final SubClass? sub;

  static const ignoreStatic = 1;

  ToFromJsonAssoc({
    this.integer,
    this.sub,
  });

  Map<String, int?> toJson() => {'integer': integer};

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
