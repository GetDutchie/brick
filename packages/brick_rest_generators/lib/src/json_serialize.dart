import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_rest_generators/src/json_serdes_generator.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:brick_core/core.dart';

mixin JsonSerialize<_Model extends Model, _Annotation extends FieldSerializable>
    on JsonSerdesGenerator<_Model, _Annotation> {
  @override
  final doesDeserialize = false;

  @override
  String? coderForField(field, checker,
      {required wrappedInFuture, required fieldAnnotation}) {
    final fieldValue =
        serdesValueForField(field, fieldAnnotation.name!, checker: checker);
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
        final nullabilitySuffix = checker.isNullable ? '?' : '';
        final nullabilityDefault = checker.isNullable ? ' ?? []' : '';
        return '''await Future.wait<Map<String, dynamic>>(
          $fieldValue$nullabilitySuffix.map((s) $awaited =>
            ${SharedChecker.withoutNullability(checker.unFuturedArgType)}Adapter().to$providerName($awaitedValue, provider: provider, repository: repository)
          ).toList()$nullabilityDefault
        )''';
      }

      return fieldValue;

      // RestModel, Future<RestModel>
    } else if (checker.isSibling) {
      final wrappedField = wrappedInFuture ? '(await $fieldValue)' : fieldValue;
      final isNullableField =
          checker.unFuturedType.nullabilitySuffix != NullabilitySuffix.none;
      final wrappedFieldWithSuffix =
          isNullableField ? '$wrappedField!' : wrappedField;

      final result =
          'await ${SharedChecker.withoutNullability(checker.unFuturedType)}Adapter().to$providerName($wrappedFieldWithSuffix, provider: provider, repository: repository)';
      if (isNullableField) return '$wrappedField != null ? $result : null';

      return result;

      // enum
    } else if (checker.isEnum) {
      if (fieldAnnotation.enumAsString) {
        final nullabilitySuffix = checker.isNullable ? '?' : '';
        return "$fieldValue$nullabilitySuffix.toString().split('.').last";
      } else {
        if (checker.isNullable) {
          return '$fieldValue != null ? ${SharedChecker.withoutNullability(field.type)}.values.indexOf($fieldValue!) : null';
        }
        return '${SharedChecker.withoutNullability(field.type)}.values.indexOf($fieldValue)';
      }
    }

    return null;
  }
}
