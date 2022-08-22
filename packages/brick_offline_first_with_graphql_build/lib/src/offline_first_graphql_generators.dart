import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql_generators/generators.dart';
import 'package:brick_graphql_generators/graphql_model_serdes_generator.dart';
import 'package:source_gen/source_gen.dart';

class _OfflineFirstGraphqlSerialize extends GraphqlSerialize
    with OfflineFirstJsonSerialize<GraphqlModel, Graphql> {
  @override
  final OfflineFirstFields offlineFirstFields;

  _OfflineFirstGraphqlSerialize(ClassElement element, GraphqlFields fields,
      {required String repositoryName})
      : offlineFirstFields = OfflineFirstFields(element),
        super(element, fields, repositoryName: repositoryName);

  @override
  String generateGraphqlDefinition(FieldElement field) {
    final annotation = offlineFirstFields.annotationForField(field);
    if (annotation.where != null && annotation.where!.length > 1) {
      final remoteName = RegExp(r'''data\[["|']([\w+\d+\-]+)["|']\]''')
          .firstMatch(annotation.where!.values.first)
          ?.group(1);
      return '''
        '${field.name}': const RuntimeGraphqlDefinition(
          association: false,
          documentNodeName: '$remoteName',
          iterable: false,
          subfields: <String>{},
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

  _OfflineFirstGraphqlDeserialize(ClassElement element, GraphqlFields fields,
      {required String repositoryName})
      : offlineFirstFields = OfflineFirstFields(element),
        super(element, fields, repositoryName: repositoryName);
}

class OfflineFirstGraphqlModelSerdesGenerator extends GraphqlModelSerdesGenerator {
  OfflineFirstGraphqlModelSerdesGenerator(Element element, ConstantReader reader,
      {required String repositoryName})
      : super(element, reader, repositoryName: repositoryName);

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
