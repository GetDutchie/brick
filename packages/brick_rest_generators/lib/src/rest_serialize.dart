import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:brick_rest_generators/src/rest_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] to REST data
class RestSerialize<_Model extends RestModel> extends RestSerdesGenerator<_Model> {
  RestSerialize(
    ClassElement element,
    RestFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final doesDeserialize = false;

  @override
  List<String> get instanceFieldsAndMethods {
    var toKey = (fields as RestFields).config?.toKey?.trim();

    if (toKey != null) toKey = "'$toKey'";

    return ['@override\nfinal String? toKey = $toKey;'];
  }

  @override
  String? coderForField(field, checker, {required wrappedInFuture, required fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);
    final defaultConstructor = element.constructors.firstWhere((e) => e.isDefaultConstructor);
    final defaultConstructorParameter =
        defaultConstructor.parameters.firstWhere((e) => e.name == field.name);

    final isNullable = defaultConstructorParameter.type.nullabilitySuffix != NullabilitySuffix.none;

    if (fieldAnnotation.ignoreTo) return null;

    // DateTime
    if (checker.isDateTime) {
      final nullabilitySuffix = isNullable ? '?' : '';
      return '$fieldValue$nullabilitySuffix.toIso8601String()';

      // bool, double, int, num, String, Map, Iterable, enum
    } else if ((checker.isDartCoreType) || checker.isMap) {
      return fieldValue;

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = checkerForType(checker.argType);

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        final nullabilitySuffix = isNullable ? '?' : '';
        if (fieldAnnotation.enumAsString) {
          return "$fieldValue$nullabilitySuffix.map((e) => e.toString().split('.').last).toList()";
        } else {
          return '$fieldValue$nullabilitySuffix.map((e) => ${SharedChecker.withoutNullability(checker.argType)}.values.indexOf(e)).toList()';
        }
      }

      // Iterable<RestModel>, Iterable<Future<RestModel>>
      if (checker.isArgTypeASibling) {
        final awaited = checker.isArgTypeAFuture ? 'async' : '';
        final awaitedValue = checker.isArgTypeAFuture ? '(await s)' : 's';
        final nullabilitySuffix = isNullable ? '?' : '';
        final nullabilityDefault = isNullable ? ' ?? []' : '';
        return '''await Future.wait<Map<String, dynamic>>(
          $fieldValue$nullabilitySuffix.map((s) $awaited =>
            ${SharedChecker.withoutNullability(checker.unFuturedArgType)}Adapter().toRest($awaitedValue, provider: provider, repository: repository)
          ).toList()$nullabilityDefault
        )''';
      }

      return fieldValue;

      // RestModel, Future<RestModel>
    } else if (checker.isSibling) {
      final wrappedField = wrappedInFuture ? '(await $fieldValue)' : fieldValue;
      final isNullableField = checker.unFuturedType.nullabilitySuffix != NullabilitySuffix.none;
      final wrappedFieldWithSuffix = isNullableField ? '$wrappedField!' : wrappedField;

      final result =
          'await ${SharedChecker.withoutNullability(checker.unFuturedType)}Adapter().toRest($wrappedFieldWithSuffix, provider: provider, repository: repository)';
      if (isNullableField) return '$wrappedField != null ? $result : null';

      return result;

      // enum
    } else if (checker.isEnum) {
      if (fieldAnnotation.enumAsString) {
        final nullabilitySuffix = isNullable ? '?' : '';
        return "$fieldValue$nullabilitySuffix.toString().split('.').last";
      } else {
        if (isNullable) {
          return '$fieldValue != null ? ${SharedChecker.withoutNullability(field.type)}.values.indexOf($fieldValue!) : null';
        }
        return '${SharedChecker.withoutNullability(field.type)}.values.indexOf($fieldValue)';
      }
    }

    return null;
  }
}
