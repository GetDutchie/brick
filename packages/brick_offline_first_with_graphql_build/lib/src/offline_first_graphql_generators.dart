import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql_generators/generators.dart';
import 'package:brick_graphql_generators/graphql_model_serdes_generator.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';

class _OfflineFirstGraphqlSerialize extends GraphqlSerialize
    with OfflineFirstJsonSerialize<GraphqlModel, Graphql> {
  @override
  final OfflineFirstFields offlineFirstFields;

  _OfflineFirstGraphqlSerialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  }) : offlineFirstFields = OfflineFirstFields(element);

  @override
  String generateGraphqlDefinition(FieldElement field) {
    final checker = checkerForType(field.type);
    final graphqlAnnotation = fields.annotationForField(field);
    final offlineFirstAnnotation = offlineFirstFields.annotationForField(field);
    if (offlineFirstAnnotation.where != null && offlineFirstAnnotation.where!.isNotEmpty) {
      final remoteName = providerNameForField(graphqlAnnotation.name, checker: checker);
      return '''
        '${field.name}': const RuntimeGraphqlDefinition(
          association: false,
          documentNodeName: '$remoteName',
          iterable: false,
          subfields: <String, Map<String, dynamic>>{},
          type: Object,
        )
      ''';
    }

    return super.generateGraphqlDefinition(field);
  }
}

class _OfflineFirstGraphqlDeserialize extends GraphqlDeserialize
    with OfflineFirstJsonDeserialize<GraphqlModel, Graphql> {
  @override
  final OfflineFirstFields offlineFirstFields;

  _OfflineFirstGraphqlDeserialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  }) : offlineFirstFields = OfflineFirstFields(element);
}

/// Produces code for `@ConnectOfflineFirstWithGraphQL`
class OfflineFirstGraphqlModelSerdesGenerator extends GraphqlModelSerdesGenerator {
  /// Produces code for `@ConnectOfflineFirstWithGraphQL`
  OfflineFirstGraphqlModelSerdesGenerator(
    super.element,
    super.reader, {
    required super.repositoryName,
  });

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = GraphqlFields(classElement, config);
    return [
      _OfflineFirstGraphqlDeserialize(classElement, fields, repositoryName: repositoryName),
      _OfflineFirstGraphqlSerialize(classElement, fields, repositoryName: repositoryName),
    ];
  }
}
