import 'package:brick_core/core.dart' show Query;
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
}) async {
  return DemoModel(
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
}

Future<Map<String, dynamic>> _$DemoModelToGraphql(
  DemoModel instance, {
  required GraphqlProvider provider,
  repository,
}) async {
  return {
    'complex_field_name': instance.complexFieldName,
    'last_name': instance.lastName,
    'full_name': instance.name,
    'simple_bool': instance.simpleBool == null ? null : (instance.simpleBool! ? 1 : 0)
  };
}

class DemoModelOperationTransformer extends GraphqlQueryOperationTransformer {
  @override
  GraphqlOperation get delete => GraphqlOperation(
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
  GraphqlOperation get upsert => GraphqlOperation(
        document: r'''mutation UpsertDemoModels($input: DemoModelInput) {
      upsertDemoModel(input: $input) {}
    }''',
      );

  const DemoModelOperationTransformer(Query? query, GraphqlModel? instance)
      : super(query, instance);
}

/// Construct a [DemoModel]
class DemoModelAdapter extends GraphqlAdapter<DemoModel> {
  @override
  final queryOperationTransformer = DemoModelOperationTransformer.new;

  DemoModelAdapter();

  @override
  Future<DemoModel> fromGraphql(
    Map<String, dynamic> input, {
    required provider,
    repository,
  }) async =>
      await _$DemoModelFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(DemoModel input, {required provider, repository}) async =>
      await _$DemoModelToGraphql(input, provider: provider, repository: repository);

  @override
  Map<String, RuntimeGraphqlDefinition> get fieldsToGraphqlRuntimeDefinition => {
        'primaryKey': const RuntimeGraphqlDefinition(
          association: false,
          documentNodeName: 'primaryKey',
          iterable: false,
          type: int,
        ),
        'id': const RuntimeGraphqlDefinition(
          association: false,
          documentNodeName: 'id',
          iterable: false,
          type: int,
        ),
        'assoc': const RuntimeGraphqlDefinition(
          association: true,
          documentNodeName: 'assoc',
          iterable: false,
          type: DemoModelAssoc,
        ),
        'someField': const RuntimeGraphqlDefinition(
          association: false,
          documentNodeName: 'someField',
          iterable: false,
          type: bool,
        ),
        'complexFieldName': const RuntimeGraphqlDefinition(
          association: false,
          documentNodeName: 'complexFieldName',
          iterable: false,
          type: String,
        ),
        'lastName': const RuntimeGraphqlDefinition(
          association: false,
          documentNodeName: 'lastName',
          iterable: false,
          type: String,
        ),
        'name': const RuntimeGraphqlDefinition(
          association: false,
          documentNodeName: 'fullName',
          iterable: false,
          type: String,
        ),
        'simpleBool': const RuntimeGraphqlDefinition(
          association: false,
          documentNodeName: 'simpleBool',
          iterable: false,
          type: bool,
        ),
      };
}
