import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/core.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:brick_json_generators/json_serdes_generator.dart';

/// Default serialize implementation of [coderForField] for JSON-based providers
mixin JsonSerialize<TModel extends Model, Annotation extends FieldSerializable>
    on JsonSerdesGenerator<TModel, Annotation> {
  @override
  final doesDeserialize = false;

  @override
  String? coderForField(
    FieldElement field,
    SharedChecker<Model> checker, {
    required bool wrappedInFuture,
    required Annotation fieldAnnotation,
  }) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);
    if (fieldAnnotation.ignoreTo) return null;

    // DateTime
    if (checker.isDateTime) {
      final nullabilitySuffix = checker.isNullable ? '?' : '';
      return '$fieldValue$nullabilitySuffix.toIso8601String()';

      // bool, double, int, num, String, Map, Iterable, enum
    } else if ((checker.isDartCoreType) || checker.isMap) {
      return fieldValue;

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = checkerForType(checker.argType);

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        final nullabilitySuffix = checker.isNullable ? '?' : '';
        final serializeMethod = argTypeChecker.enumSerializeMethod(providerName);
        if (serializeMethod != null) {
          return '$fieldValue$nullabilitySuffix.map((e) => e.$serializeMethod()).toList()';
        }

        if (fieldAnnotation.enumAsString) {
          return '$fieldValue$nullabilitySuffix.map((e) => e.name).toList()';
        } else {
          return '$fieldValue$nullabilitySuffix.map((e) => ${SharedChecker.withoutNullability(checker.argType)}.values.indexOf(e)).toList()';
        }
      }

      // Iterable<RestModel>, Iterable<Future<RestModel>>
      if (checker.isArgTypeASibling) {
        final awaited = checker.isArgTypeAFuture ? 'async' : '';
        final awaitedValue = checker.isArgTypeAFuture ? '(await s)' : 's';
        final nullabilitySuffix = checker.isNullable ? '?' : '';
        final nullabilityDefault = checker.isNullable ? ' ?? []' : '';
        return '''await Future.wait<Map<String, dynamic>>(
          $fieldValue$nullabilitySuffix.map((s) $awaited =>
            ${SharedChecker.withoutNullability(checker.unFuturedArgType)}Adapter().to$providerName($awaitedValue, provider: provider, repository: repository)
          ).toList()$nullabilityDefault
        )''';
      }

      // Iterable<toJson>
      if (argTypeChecker.toJsonMethod != null) {
        final nullabilitySuffix = checker.isNullable ? '?' : '';
        return '$fieldValue$nullabilitySuffix.map((s) => s.toJson()).toList()';
      }

      return fieldValue;

      // RestModel, Future<RestModel>
    } else if (checker.isSibling) {
      final wrappedField = wrappedInFuture ? '(await $fieldValue)' : fieldValue;
      final isNullableField = checker.unFuturedType.nullabilitySuffix != NullabilitySuffix.none;
      final wrappedFieldWithSuffix = isNullableField ? '$wrappedField!' : wrappedField;

      final result =
          'await ${SharedChecker.withoutNullability(checker.unFuturedType)}Adapter().to$providerName($wrappedFieldWithSuffix, provider: provider, repository: repository)';
      if (isNullableField) return '$wrappedField != null ? $result : null';

      return result;

      // enum
    } else if (checker.isEnum) {
      final nullabilitySuffix = checker.isNullable ? '?' : '';
      final serializeMethod = checker.enumSerializeMethod(providerName);
      if (serializeMethod != null) {
        return '$fieldValue$nullabilitySuffix.$serializeMethod()';
      }

      if (fieldAnnotation.enumAsString) {
        return '$fieldValue$nullabilitySuffix.name';
      } else {
        if (checker.isNullable) {
          return '$fieldValue != null ? ${SharedChecker.withoutNullability(field.type)}.values.indexOf($fieldValue!) : null';
        }
        return '${SharedChecker.withoutNullability(field.type)}.values.indexOf($fieldValue)';
      }
    } else if (checker.toJsonMethod != null) {
      final nullabilitySuffix = checker.isNullable ? '?' : '';
      return '$fieldValue$nullabilitySuffix.toJson()';
    }

    return null;
  }
}
