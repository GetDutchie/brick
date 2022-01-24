import 'package:brick_graphql/graphql.dart';
import 'package:gql/src/ast/ast.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';

import 'demo_model.dart';
import 'package:brick_core/core.dart' show Query;

Future<DemoModel> _$DemoModelFromGraphql(Map<String, dynamic> data,
    {GraphQLProvider? provider, repository}) async {
  return DemoModel(
      name: data['full_name'] == null ? null : data['full_name'] as String,
      assoc: data['assoc_DemoModelAssoc_brick_id'] == null
          ? null
          : (data['assoc_DemoModelAssoc_brick_id'] > -1
              ? (await repository?.getAssociation<DemoModelAssoc>(
                  Query.where('primaryKey', data['assoc_DemoModelAssoc_brick_id'] as int,
                      limit1: true),
                ))
                  ?.first
              : null),
      complexFieldName:
          data['complex_field_name'] == null ? null : data['complex_field_name'] as String,
      lastName: data['last_name'] == null ? null : data['last_name'] as String,
      simpleBool: data['simple_bool'] == null ? null : data['simple_bool'] == 1);
}

Future<Map<String, dynamic>> _$DemoModelToGraphql(DemoModel instance,
    {required GraphQLProvider provider, repository}) async {
  return {
    'complex_field_name': instance.complexFieldName,
    'last_name': instance.lastName,
    'full_name': instance.name,
    'simple_bool': instance.simpleBool == null ? null : (instance.simpleBool! ? 1 : 0)
  };
}

/// Construct a [DemoModel]
class DemoModelAdapter extends GraphQLAdapter<DemoModel> {
  DemoModelAdapter();

  @override
  Future<DemoModel> fromGraphQL(Map<String, dynamic> input,
          {required provider, repository}) async =>
      await _$DemoModelFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphQL(DemoModel input, {required provider, repository}) async =>
      await _$DemoModelToGraphql(input, provider: provider, repository: repository);

  @override
  // TODO: implement fieldsToRuntimeDefinition
  Map<String, RuntimeGraphqlDefinition> get fieldsToRuntimeDefinition => {};

  @override
  // TODO: implement mututationEndpoint
  DocumentNode get mututationEndpoint => throw UnimplementedError();
}
