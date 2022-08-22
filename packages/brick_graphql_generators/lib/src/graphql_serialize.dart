import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_graphql_generators/src/graphql_serdes_generator.dart';
import 'package:brick_json_generators/json_serialize.dart';

/// Generate a function to produce a [ClassElement] from GraphQL data
class GraphqlSerialize extends GraphqlSerdesGenerator with JsonSerialize<GraphqlModel, Graphql> {
  GraphqlSerialize(
    ClassElement element,
    GraphqlFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  List<String> get instanceFieldsAndMethods {
    final fieldsToColumns = unignoredFields.fold<List<String>>([], (fields, field) {
      final definition = generateGraphqlDefinition(field);
      fields.add(definition);
      return fields;
    });

    return [
      '@override\nfinal Map<String, RuntimeGraphqlDefinition> fieldsToGraphqlRuntimeDefinition = {${fieldsToColumns.join(',\n')}};',
    ];
  }

  String _finalTypeForField(DartType type) {
    final typeRemover = RegExp(r'\<[,\s\w]+\>');
    final checker = checkerForType(type);
    // Future<?>, Iterable<?>
    if (checker.isFuture || checker.isIterable) {
      return _finalTypeForField(checker.argType);
    }

    if (checker.toJsonMethod != null) {
      return checker.toJsonMethod!.returnType
          .getDisplayString(withNullability: false)
          .replaceAll(typeRemover, '');
    }

    // remove arg types as they can't be declared in final fields
    return type.getDisplayString(withNullability: false).replaceAll(typeRemover, '');
  }

  String generateGraphqlDefinition(FieldElement field) {
    final annotation = fields.annotationForField(field);
    final checker = checkerForType(field.type);
    final remoteName = providerNameForField(annotation.name, checker: checker);
    final columnInsertionType = _finalTypeForField(field.type);
    final subfields =
        (annotation.subfields ?? _subfieldsForType(field.type)).map((f) => "'$f'").join(',');

    // T0D0 support List<Future<Sibling>> for 'association'
    return '''
      '${field.name}': const RuntimeGraphqlDefinition(
        association: ${checker.isSibling || (checker.isIterable && checker.isArgTypeASibling)},
        documentNodeName: '$remoteName',
        iterable: ${checker.isIterable},
        subfields: <String>{$subfields},
        type: $columnInsertionType,
      )
    ''';
  }

  Set<String> _subfieldsForType(DartType type) {
    final checker = checkerForType(type);
    // Future<?>, Iterable<?>
    if (checker.isFuture || checker.isIterable) {
      return _subfieldsForType(checker.argType);
    }

    if (checker.toJsonMethod != null && checker.toJsonMethod!.returnType.isDartCoreMap) {
      if (type.element is ClassElement) {
        final klass = type.element as ClassElement;
        final subfields = klass.fields.where((field) {
          return field.isPublic &&
              ((field.isFinal || field.isConst) && field.getter != null) &&
              !field.isStatic &&
              !field.type.isDartCoreFunction;
        }).where((field) => !FieldsForClass.isComputedGetter(field));
        return subfields.map((field) => field.name).toSet();
      }
    }

    return <String>{};
  }
}
