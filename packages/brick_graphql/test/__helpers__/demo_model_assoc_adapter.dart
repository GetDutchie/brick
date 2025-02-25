import 'package:brick_core/src/model_repository.dart';
import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:brick_graphql/src/transformers/graphql_query_operation_transformer.dart';

import 'demo_model.dart';

Future<DemoModelAssoc> _$DemoModelAssocFromGraphql(
  Map<String, dynamic> data, {
  GraphqlProvider? provider,
  repository,
}) async =>
    DemoModelAssoc(name: data['full_name'] == null ? null : data['full_name'] as String);

Future<Map<String, dynamic>> _$DemoModelAssocToGraphql(
  DemoModelAssoc instance, {
  GraphqlProvider? provider,
  repository,
}) async =>
    {'full_name': instance.name};

/// Construct a [DemoModelAssoc]
class DemoModelAssocAdapter extends GraphqlAdapter<DemoModelAssoc> {
  @override
  final queryOperationTransformer = _DemoModelAssocTransformer.new;

  DemoModelAssocAdapter();

  @override
  final fieldsToGraphqlRuntimeDefinition = {
    'primaryKey': const RuntimeGraphqlDefinition(
      documentNodeName: 'primaryKey',
      type: int,
    ),
    'name': const RuntimeGraphqlDefinition(
      documentNodeName: 'fullName',
      type: String,
    ),
  };

  @override
  Future<DemoModelAssoc> fromGraphql(
    Map<String, dynamic> input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  }) async =>
      await _$DemoModelAssocFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(
    DemoModelAssoc input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  }) async =>
      await _$DemoModelAssocToGraphql(input, provider: provider, repository: repository);
}

class _DemoModelAssocTransformer extends GraphqlQueryOperationTransformer {
  @override
  GraphqlOperation get get => const GraphqlOperation(
        document: '''query GetDemoAssocModels() {
          getDemoAssocModels() {}
        }''',
      );

  const _DemoModelAssocTransformer(super.query, GraphqlModel? super.instance);
}

class DemoModelAssocWithSubfieldsAdapter extends GraphqlAdapter<DemoModelAssoc> {
  DemoModelAssocWithSubfieldsAdapter();
  @override
  final queryOperationTransformer = _DemoModelAssocTransformer.new;

  @override
  final fieldsToGraphqlRuntimeDefinition = <String, RuntimeGraphqlDefinition>{
    'primaryKey': const RuntimeGraphqlDefinition(
      documentNodeName: '_brick_id',
      type: int,
    ),
    'name': const RuntimeGraphqlDefinition(
      documentNodeName: 'full_name',
      subfields: {
        'first': {'subfield1': {}},
        'last': {},
      },
      type: String,
    ),
  };

  @override
  Future<DemoModelAssoc> fromGraphql(
    Map<String, dynamic> input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  }) async =>
      await _$DemoModelAssocFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(
    DemoModelAssoc input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  }) async =>
      await _$DemoModelAssocToGraphql(input, provider: provider, repository: repository);
}
