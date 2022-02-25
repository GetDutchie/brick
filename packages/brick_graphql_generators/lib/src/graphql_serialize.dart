import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
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
    final fieldsToColumns = <String>[];

    for (final field in unignoredFields) {
      final annotation = fields.annotationForField(field);
      final checker = checkerForType(field.type);
      final remoteName = providerNameForField(annotation.name, checker: checker);
      final columnInsertionType = _finalTypeForField(field.type);

      // T0D0 support List<Future<Sibling>> for 'association'
      fieldsToColumns.add('''
          '${field.name}': const RuntimeGraphqlDefinition(
            association: ${checker.isSibling || (checker.isIterable && checker.isArgTypeASibling)},
            documentNodeName: '$remoteName',
            iterable: ${checker.isIterable},
            type: $columnInsertionType,
          )''');
    }

    return [
      '@override\nfinal Map<String, RuntimeGraphqlDefinition> fieldsToGraphqlRuntimeDefinition = {${fieldsToColumns.join(',\n')}};',
    ];
  }

  String _finalTypeForField(DartType type) {
    final checker = checkerForType(type);
    // Future<?>, Iterable<?>
    if (checker.isFuture || checker.isIterable) {
      return _finalTypeForField(checker.argType);
    }

    if (checker.toJsonMethod != null) {
      return checker.toJsonMethod!.returnType.getDisplayString(withNullability: false);
    }

    // remove arg types as they can't be declared in final fields
    return type.getDisplayString(withNullability: false).replaceAll(RegExp(r'\<[,\s\w]+\>'), '');
  }
}
