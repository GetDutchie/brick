import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_rest_build/src/rest_fields.dart';
import 'package:brick_rest_build/src/rest_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] to REST data
class RestSerialize extends RestSerdesGenerator {
  RestSerialize(
    ClassElement element,
    RestFields fields, {
    String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final providerName = RestSerdesGenerator.REST_PROVIDER_NAME;

  @override
  final doesDeserialize = false;

  @override
  String get adapterMethod =>
      'await $serializingFunctionName(input, provider: provider, repository: repository)';

  @override
  List<String> get instanceFieldsAndMethods {
    var toKey = (fields as RestFields).config?.toKey?.trim();

    if (toKey != null) toKey = "'$toKey'";

    return ['final String toKey = $toKey;'];
  }

  @override
  String coderForField(field, checker, {offlineFirstAnnotation, wrappedInFuture, fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
    if (fieldAnnotation.ignoreTo) return null;

    if (offlineFirstAnnotation.where != null && offlineFirstAnnotation.where.length > 1) {
      return null;
    }

    // DateTime
    if (checker.isDateTime) {
      return '$fieldValue?.toIso8601String()';

      // bool, double, int, num, String, Map, Iterable, enum
    } else if ((checker.isDartCoreType) || checker.isMap) {
      return '$fieldValue';

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = SharedChecker(checker.argType);

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        if (fieldAnnotation.enumAsString) {
          return "$fieldValue?.map((e) => e.toString().split('.').last)";
        } else {
          return '$fieldValue?.map((e) => ${checker.argType.getDisplayString()}.values.indexOf(e))';
        }
      }

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
