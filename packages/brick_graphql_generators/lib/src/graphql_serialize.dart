import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql_generators/src/graphql_serdes_generator.dart';
import 'package:brick_json_generators/json_serialize.dart';

/// Generate a function to produce a [ClassElement] from GraphQL data
class GraphqlSerialize extends GraphqlSerdesGenerator with JsonSerialize<GraphqlModel, Graphql> {
  @override
  Iterable<FieldElement> get unignoredFields {
    return fields.stableInstanceFields.where((field) {
      final annotation = fields.annotationForField(field);
      final checker = checkerForType(field.type);

      return !annotation.ignore &&
          (checker.isSerializable || checker.isSerializableViaJson(doesDeserialize));
    });
  }

  /// Generate a function to produce a [ClassElement] from GraphQL data
  GraphqlSerialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });

  @override
  List<String> get instanceFieldsAndMethods {
    final fieldsToColumns = unignoredFields.fold<List<String>>([], (fields, field) {
      final definition = generateGraphqlDefinition(field);
      fields.add(definition);
      return fields;
    });

    return [
      '@override\nfinal fieldsToGraphqlRuntimeDefinition = <String, RuntimeGraphqlDefinition>{${fieldsToColumns.join(',\n')}};',
    ];
  }

  /// Produce a map entry of a [RuntimeGraphqlDefinition] from a [FieldElement].
  String generateGraphqlDefinition(FieldElement field) {
    final annotation = fields.annotationForField(field);
    final checker = checkerForType(field.type);
    final remoteName = providerNameForField(annotation.name, checker: checker);
    final columnInsertionType = checker.withoutNullResultType;
    final subfields = (annotation.subfields ?? _subfieldsForType(field.type))
        .entries
        .fold<List<String>>(<String>[], (acc, entry) {
      acc.add(_convertMapToString(entry));
      return acc;
    }).join(',');

    // T0D0 support List<Future<Sibling>> for 'association'
    return '''
      '${field.name}': const RuntimeGraphqlDefinition(
        association: ${checker.isSibling || (checker.isIterable && checker.isArgTypeASibling)},
        documentNodeName: '$remoteName',
        iterable: ${checker.isIterable},
        subfields: <String, Map<String, dynamic>>{$subfields},
        type: $columnInsertionType,
      )
    ''';
  }

  Map<String, Map<String, dynamic>> _subfieldsForType(DartType type) {
    final checker = checkerForType(type);
    // Future<?>, Iterable<?>
    if (checker.isFuture || checker.isIterable) {
      return _subfieldsForType(checker.argType);
    }

    if (checker.toJsonMethod != null && checker.toJsonMethod!.returnType.isDartCoreMap) {
      if (type.element is ClassElement) {
        final klass = type.element! as ClassElement;
        final subfields = klass.fields.where((field) {
          return field.isPublic &&
              ((field.isFinal || field.isConst) && field.getter != null) &&
              !field.isStatic &&
              !field.type.isDartCoreFunction &&
              !FieldsForClass.isComputedGetter(field);
        }).whereType<FieldElement>();

        return subfields.fold<Map<String, Map<String, dynamic>>>({}, (acc, field) {
          final fieldChecker = checkerForField(field);
          final isSerializable =
              fieldChecker.toJsonMethod != null && checker.toJsonMethod!.returnType.isDartCoreMap;
          acc[field.name] = isSerializable ? _subfieldsForType(field.type) : {};
          return acc;
        });
      }
    }

    return {};
  }

  static String _convertMapToString(MapEntry entry) {
    if ((entry.value as Map).isEmpty) return "'${entry.key}': {}";
    return "'${entry.key}': {${entry.value.entries.map(_convertMapToString).join(',')}}";
  }
}
