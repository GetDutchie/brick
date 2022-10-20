import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:brick_graphql/src/transformers/graphql_query_operation_transformer.dart';

import 'demo_model.dart';

Future<DemoModelAssoc> _$DemoModelAssocFromGraphql(Map<String, dynamic> data,
    {GraphqlProvider? provider, repository}) async {
  return DemoModelAssoc(name: data['full_name'] == null ? null : data['full_name'] as String);
}

Future<Map<String, dynamic>> _$DemoModelAssocToGraphql(DemoModelAssoc instance,
    {GraphqlProvider? provider, repository}) async {
  return {'full_name': instance.name};
}

/// Construct a [DemoModelAssoc]
class DemoModelAssocAdapter extends GraphqlAdapter<DemoModelAssoc> {
  @override
  final queryOperationTransformer = _DemoModelAssocTransformer.new;

  DemoModelAssocAdapter();

  @override
  final Map<String, RuntimeGraphqlDefinition> fieldsToGraphqlRuntimeDefinition = {
    'primaryKey': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'primaryKey',
      iterable: false,
      type: int,
    ),
    'name': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'fullName',
      iterable: false,
      type: String,
    ),
  };

  @override
  Future<DemoModelAssoc> fromGraphql(Map<String, dynamic> input,
          {required provider, repository}) async =>
      await _$DemoModelAssocFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(DemoModelAssoc input,
          {required provider, repository}) async =>
      await _$DemoModelAssocToGraphql(input, provider: provider, repository: repository);
}

class _DemoModelAssocTransformer extends GraphqlQueryOperationTransformer {
  @override
  GraphqlOperation get get => GraphqlOperation(
        document: r'''query GetDemoAssocModels() {
          getDemoAssocModels() {}
        }''',
      );

  const _DemoModelAssocTransformer(Query? query, GraphqlModel? instance) : super(query, instance);
}

class DemoModelAssocWithSubfieldsAdapter extends GraphqlAdapter<DemoModelAssoc> {
  DemoModelAssocWithSubfieldsAdapter();
  @override
  final queryOperationTransformer = _DemoModelAssocTransformer.new;

  @override
  final Map<String, RuntimeGraphqlDefinition> fieldsToGraphqlRuntimeDefinition = {
    'primaryKey': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'name': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'full_name',
      iterable: false,
      subfields: {
        'first': {'subfield1': {}},
        'last': {}
      },
      type: String,
    ),
  };

  @override
  Future<DemoModelAssoc> fromGraphql(Map<String, dynamic> input,
          {required provider, repository}) async =>
      await _$DemoModelAssocFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(DemoModelAssoc input,
          {required provider, repository}) async =>
      await _$DemoModelAssocToGraphql(input, provider: provider, repository: repository);
}
