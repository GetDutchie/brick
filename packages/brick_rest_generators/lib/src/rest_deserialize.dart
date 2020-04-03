import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:brick_rest_generators/src/rest_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] from REST data
class RestDeserialize extends RestSerdesGenerator {
  RestDeserialize(
    ClassElement element,
    RestFields fields, {
    String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final doesDeserialize = true;

  @override
  List<String> get instanceFieldsAndMethods {
    var endpoint = (fields as RestFields).config?.endpoint?.trim() ?? "=> ''";
    var fromKey = (fields as RestFields).config?.fromKey?.trim();
    if (!endpoint.endsWith(';') && !endpoint.endsWith('}')) {
      endpoint += ';';
    }

    if (fromKey != null) fromKey = "'$fromKey'";

    return ['String restEndpoint({query, instance}) $endpoint', 'final String fromKey = $fromKey;'];
  }

  @override
  String coderForField(field, checker, {wrappedInFuture, fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
    final defaultValue = SerdesGenerator.defaultValueSuffix(fieldAnnotation);

    if (fieldAnnotation.ignoreFrom) return null;

    // DateTime
    if (checker.isDateTime) {
      return "$fieldValue == null ? null : DateTime.tryParse($fieldValue$defaultValue as String)";

      // bool, double, int, num, String
    } else if (checker.isDartCoreType) {
      return "$fieldValue as ${field.type}$defaultValue";

      // Iterable
    } else if (checker.isIterable) {
      final argType = checker.unFuturedArgType;
      final argTypeChecker = checkerForType(checker.argType);
      final castIterable = SerdesGenerator.iterableCast(argType,
          isSet: checker.isSet,
          isList: checker.isList,
          isFuture: wrappedInFuture || checker.isFuture);

      // Iterable<RestModel>, Iterable<Future<RestModel>>
      if (checker.isArgTypeASibling) {
        final fromRestCast = SerdesGenerator.iterableCast(argType,
            isSet: checker.isSet, isList: checker.isList, isFuture: true);

        var deserializeMethod = '''
          $fieldValue?.map((d) =>
            ${argType}Adapter().fromRest(d, provider: provider, repository: repository)
          )$fromRestCast
        ''';

        if (wrappedInFuture) {
          deserializeMethod = 'Future.wait<$argType>($deserializeMethod ?? [])';
        } else if (!checker.isArgTypeAFuture && !checker.isFuture) {
          deserializeMethod = 'await Future.wait<$argType>($deserializeMethod ?? [])';
        }

        if (checker.isSet) {
          return '($deserializeMethod$defaultValue)?.toSet()';
        }

        return '$deserializeMethod$defaultValue';
      }

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        if (fieldAnnotation.enumAsString) {
          return '''$fieldValue.map((value) =>
              $argType.values.firstWhere((e) => e.toString().split('.').last == value, orElse: () => null)
            )$castIterable$defaultValue
          ''';
        } else {
          return "$fieldValue.map((e) => $argType.values[e])$castIterable$defaultValue";
        }
      }

      // List
      if (checker.isList) {
        final addon = fieldAnnotation.defaultValue ?? 'List<${checker.argType}>()';
        return "$fieldValue$castIterable ?? $addon";

        // Set
      } else if (checker.isSet) {
        final addon = fieldAnnotation.defaultValue ?? 'Set<${checker.argType}>()';
        return "$fieldValue$castIterable ?? $addon";

        // other Iterable
      } else {
        return "$fieldValue$castIterable$defaultValue";
      }

      // RestModel
    } else if (checker.isSibling) {
      final shouldAwait = wrappedInFuture ? '' : 'await ';

      return '''$shouldAwait${checker.unFuturedType}Adapter().fromRest(
          $fieldValue, provider: provider, repository: repository
        )''';

      // enum
    } else if (checker.isEnum) {
      if (fieldAnnotation.enumAsString) {
        return "${field.type}.values.firstWhere((h) => h.toString().split('.').last == $fieldValue, orElse: () => null)$defaultValue";
      } else {
        return "$fieldValue is int ? ${field.type}.values[$fieldValue as int] : null$defaultValue";
      }

      // Map
    } else if (checker.isMap) {
      return "$fieldValue$defaultValue";
    }

    return null;
  }
}
