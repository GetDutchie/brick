import 'package:brick_core/core.dart' show Query;
import 'package:brick_core/src/model_repository.dart';
import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:brick_graphql/src/transformers/graphql_query_operation_transformer.dart';

import 'demo_model.dart';

Future<DemoModel> _$DemoModelFromGraphql(
  Map<String, dynamic> data, {
  GraphqlProvider? provider,
  repository,
}) async =>
    DemoModel(
      name: data['full_name'] == null ? null : data['full_name'] as String,
      assoc: data['assoc_DemoModelAssoc_brick_id'] == null
          ? null
          : (data['assoc_DemoModelAssoc_brick_id'] > -1
              ? (await repository?.getAssociation<DemoModelAssoc>(
                  Query.where(
                    'primaryKey',
                    data['assoc_DemoModelAssoc_brick_id'] as int,
                    limit1: true,
                  ),
                ))
                  ?.first
              : null),
      complexFieldName:
          data['complex_field_name'] == null ? null : data['complex_field_name'] as String,
      lastName: data['last_name'] == null ? null : data['last_name'] as String,
      simpleBool: data['simple_bool'] == null ? null : data['simple_bool'] == 1,
    );

Future<Map<String, dynamic>> _$DemoModelToGraphql(
  DemoModel instance, {
  required GraphqlProvider provider,
  repository,
}) async =>
    {
      'complex_field_name': instance.complexFieldName,
      'last_name': instance.lastName,
      'full_name': instance.name,
      'simple_bool': instance.simpleBool == null ? null : (instance.simpleBool! ? 1 : 0),
    };

class DemoModelOperationTransformer extends GraphqlQueryOperationTransformer {
  @override
  GraphqlOperation get delete => const GraphqlOperation(
        document: r'''mutation DeleteDemoModel($input: DemoModelInput!) {
      deleteDemoModel(input: $input) {}
    }''',
      );

  @override
  GraphqlOperation get get {
    var document = '''query GetDemoModels() {
      getDemoModels() {}
    }''';

    if (query?.where != null) {
      document = r'''query GetDemoModel($input: DemoModelFilterInput) {
        getDemoModel(input: $input) {}
      }''';
    }
    return GraphqlOperation(document: document);
  }

  @override
  GraphqlOperation get subscribe {
    var document = '''subscription GetDemoModels() {
      getDemoModels() {}
    }''';

    if (query?.where != null) {
      document = r'''subscription GetDemoModels($input: DemoModelInput) {
      getDemoModels(input: $input) {}
    }''';
    }
    return GraphqlOperation(document: document);
  }

  @override
  GraphqlOperation get upsert => const GraphqlOperation(
        document: r'''mutation UpsertDemoModels($input: DemoModelInput) {
      upsertDemoModel(input: $input) {}
    }''',
      );

  const DemoModelOperationTransformer(super.query, GraphqlModel? super.instance);
}

/// Construct a [DemoModel]
class DemoModelAdapter extends GraphqlAdapter<DemoModel> {
  @override
  final queryOperationTransformer = DemoModelOperationTransformer.new;

  DemoModelAdapter();

  @override
  Future<DemoModel> fromGraphql(
    Map<String, dynamic> input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  }) async =>
      await _$DemoModelFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(
    DemoModel input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  }) async =>
      await _$DemoModelToGraphql(input, provider: provider, repository: repository);

  @override
  Map<String, RuntimeGraphqlDefinition> get fieldsToGraphqlRuntimeDefinition => {
        'primaryKey': const RuntimeGraphqlDefinition(
          documentNodeName: 'primaryKey',
          type: int,
        ),
        'id': const RuntimeGraphqlDefinition(
          documentNodeName: 'id',
          type: int,
        ),
        'assoc': const RuntimeGraphqlDefinition(
          association: true,
          documentNodeName: 'assoc',
          type: DemoModelAssoc,
        ),
        'someField': const RuntimeGraphqlDefinition(
          documentNodeName: 'someField',
          type: bool,
        ),
        'complexFieldName': const RuntimeGraphqlDefinition(
          documentNodeName: 'complexFieldName',
          type: String,
        ),
        'lastName': const RuntimeGraphqlDefinition(
          documentNodeName: 'lastName',
          type: String,
        ),
        'name': const RuntimeGraphqlDefinition(
          documentNodeName: 'fullName',
          type: String,
        ),
        'simpleBool': const RuntimeGraphqlDefinition(
          documentNodeName: 'simpleBool',
          type: bool,
        ),
      };
}
