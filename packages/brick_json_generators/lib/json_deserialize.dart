import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/core.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:brick_json_generators/json_serdes_generator.dart';

/// Default deserialize implementation of [coderForField] for JSON-based providers
mixin JsonDeserialize<TModel extends Model, Annotation extends FieldSerializable>
    on JsonSerdesGenerator<TModel, Annotation> {
  @override
  final doesDeserialize = true;

  @override
  String? coderForField(
    FieldElement field,
    SharedChecker<Model> checker, {
    required bool wrappedInFuture,
    required Annotation fieldAnnotation,
  }) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);
    final defaultValue = SerdesGenerator.defaultValueSuffix(fieldAnnotation);
    if (fieldAnnotation.ignoreFrom) return null;

    // DateTime
    if (checker.isDateTime) {
      if (checker.isNullable) {
        return '$fieldValue == null ? null : DateTime.tryParse($fieldValue$defaultValue as String)';
      }
      return 'DateTime.parse($fieldValue$defaultValue as String)';

      // bool, double, int, num, String
    } else if (checker.isDartCoreType) {
      final wrappedCheckerType =
          wrappedInFuture ? 'Future<${checker.targetType}>' : checker.targetType.toString();
      return '$fieldValue as $wrappedCheckerType$defaultValue';

      // Iterable
    } else if (checker.isIterable) {
      final argType = checker.unFuturedArgType;
      final argTypeChecker = checkerForType(checker.argType);
      final castIterable = SerdesGenerator.iterableCast(
        argType,
        isSet: checker.isSet,
        isList: checker.isList,
        isFuture: wrappedInFuture || checker.isFuture,
        forceCast: !checker.isArgTypeASibling,
      );

      // Iterable<RestModel>, Iterable<Future<RestModel>>
      if (checker.isArgTypeASibling) {
        final fromJsonCast = SerdesGenerator.iterableCast(
          argType,
          isSet: checker.isSet,
          isList: checker.isList,
          isFuture: true,
          forceCast: true,
        );

        var deserializeMethod = '''
          $fieldValue?.map((d) =>
            ${SharedChecker.withoutNullability(argType)}Adapter().from$providerName(d, provider: provider, repository: repository)
          )$fromJsonCast
        ''';

        if (wrappedInFuture) {
          deserializeMethod = 'Future.wait<$argType>($deserializeMethod ?? [])';
        } else if (!checker.isArgTypeAFuture && !checker.isFuture) {
          deserializeMethod = 'await Future.wait<$argType>($deserializeMethod ?? [])';
        }

        if (checker.isSet) {
          return '($deserializeMethod$defaultValue).toSet()';
        }

        return '$deserializeMethod$defaultValue';
      }

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        final deserializeFactory = argTypeChecker.enumDeserializeFactory(providerName);
        if (deserializeFactory != null) {
          final nullableSuffix = argTypeChecker.isNullable ? '?' : '';
          return '$fieldValue$nullableSuffix.map(${SharedChecker.withoutNullability(argType)}.$deserializeFactory)';
        }

        if (fieldAnnotation.enumAsString) {
          return '''$fieldValue.whereType<String>().map(
            ${SharedChecker.withoutNullability(argType)}.values.byName
          )$castIterable$defaultValue
          ''';
        } else {
          return '$fieldValue.map((e) => ${SharedChecker.withoutNullability(argType)}.values[e])$castIterable$defaultValue';
        }
      }

      // Iterable<fromJson>
      if (argTypeChecker.fromJsonConstructor != null) {
        final klass = argTypeChecker.targetType.element! as ClassElement;
        final parameterType = argTypeChecker.fromJsonConstructor!.parameters.first.type;
        final nullableSuffix = checker.isNullable ? '?' : '';

        return '''$fieldValue$nullableSuffix.map(
          (d) => ${klass.displayName}.fromJson(d as ${parameterType.getDisplayString()})
        )$castIterable$defaultValue''';
      }

      // List, Set, other iterable
      final deserializeMethod =
          checker.isNullable ? '$fieldValue?$castIterable' : '$fieldValue$castIterable';
      return fieldAnnotation.defaultValue == null
          ? deserializeMethod
          : '$deserializeMethod ?? ${fieldAnnotation.defaultValue}';

      // sibling
    } else if (checker.isSibling) {
      final shouldAwait = wrappedInFuture ? '' : 'await ';

      return '''$shouldAwait${SharedChecker.withoutNullability(checker.unFuturedType)}Adapter().from$providerName(
          $fieldValue, provider: provider, repository: repository
        )''';

      // enum
    } else if (checker.isEnum) {
      final deserializeFactory = checker.enumDeserializeFactory(providerName);
      if (deserializeFactory != null) {
        return '${SharedChecker.withoutNullability(field.type)}.$deserializeFactory($fieldValue)';
      }

      if (fieldAnnotation.enumAsString) {
        return '${SharedChecker.withoutNullability(field.type)}.values.byName($fieldValue)$defaultValue';
      } else {
        if (checker.isNullable) {
          return '$fieldValue is int ? ${SharedChecker.withoutNullability(field.type)}.values[$fieldValue as int] : null$defaultValue';
        }
        return '${SharedChecker.withoutNullability(field.type)}.values[$fieldValue as int]';
      }

      // Map
    } else if (checker.isMap) {
      return '$fieldValue$defaultValue';
    } else if (checker.fromJsonConstructor != null) {
      final klass = checker.targetType.element! as ClassElement;
      final parameterType = checker.fromJsonConstructor!.parameters.first.type;

      return '${klass.displayName}.fromJson($fieldValue as ${parameterType.getDisplayString()})';
    }

    return null;
  }
}
