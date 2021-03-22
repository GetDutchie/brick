import 'package:analyzer/dart/element/element.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:brick_rest_generators/src/rest_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] to REST data
class RestSerialize<_Model extends RestModel> extends RestSerdesGenerator<_Model> {
  RestSerialize(
    ClassElement element,
    RestFields fields, {
    String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final doesDeserialize = false;

  @override
  List<String> get instanceFieldsAndMethods {
    var toKey = (fields as RestFields).config?.toKey?.trim();

    if (toKey != null) toKey = "'$toKey'";

    return ['@override\nfinal String toKey = $toKey;'];
  }

  @override
  String coderForField(field, checker, {wrappedInFuture, fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
    if (fieldAnnotation.ignoreTo) return null;

    // DateTime
    if (checker.isDateTime) {
      return '$fieldValue?.toIso8601String()';

      // bool, double, int, num, String, Map, Iterable, enum
    } else if ((checker.isDartCoreType) || checker.isMap) {
      return fieldValue;

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = checkerForType(checker.argType);

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        if (fieldAnnotation.enumAsString) {
          return "$fieldValue?.map((e) => e.toString().split('.').last)?.toList()";
        } else {
          return '$fieldValue?.map((e) => ${checker.argType.getDisplayString()}.values.indexOf(e))?.toList()';
        }
      }

      // Iterable<RestModel>, Iterable<Future<RestModel>>
      if (checker.isArgTypeASibling) {
        final awaited = checker.isArgTypeAFuture ? 'async' : '';
        final awaitedValue = checker.isArgTypeAFuture ? '(await s)' : 's';
        return '''await Future.wait<Map<String, dynamic>>(
          $fieldValue?.map((s) $awaited =>
            ${checker.unFuturedArgType}Adapter().toRest($awaitedValue, provider: provider, repository: repository)
          ).toList() ?? []
        )''';
      }

      return fieldValue;

      // RestModel, Future<RestModel>
    } else if (checker.isSibling) {
      final wrappedField = wrappedInFuture ? '(await $fieldValue)' : fieldValue;

      return 'await ${checker.unFuturedType}Adapter().toRest($wrappedField, provider: provider, repository: repository)';

      // enum
    } else if (checker.isEnum) {
      if (fieldAnnotation.enumAsString) {
        return "$fieldValue?.toString()?.split('.')?.last";
      } else {
        return '$fieldValue != null ? ${field.type}.values.indexOf($fieldValue) : null';
      }
    }

    return null;
  }
}
