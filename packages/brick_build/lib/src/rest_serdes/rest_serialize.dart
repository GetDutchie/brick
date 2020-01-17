import 'package:analyzer/dart/element/element.dart';
import 'package:brick_rest/rest.dart' show Rest;
import 'package:brick_build/src/offline_first/offline_first_checker.dart';
import 'package:brick_build/src/offline_first/offline_first_serdes_generator.dart';
import 'package:brick_build/src/rest_serdes/rest_fields.dart';

/// Generate a function to produce a [ClassElement] from SQLite data
class RestSerialize extends OfflineFirstSerdesGenerator<Rest> {
  RestSerialize(
    ClassElement element,
    RestFields fields, {
    String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final providerName = OfflineFirstSerdesGenerator.REST_PROVIDER_NAME;

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
      final argTypeChecker = OfflineFirstChecker(checker.argType);

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        if (fieldAnnotation.enumAsString) {
          return "$fieldValue?.map((e) => e.toString().split('.').last)";
        } else {
          return '$fieldValue?.map((e) => ${checker.argType.getDisplayString()}.values.indexOf(e))';
        }
      }

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasSerializer = hasSerializer(checker.argType);
        if (_hasSerializer) {
          return '$fieldValue?.map((${checker.argType.getDisplayString()} c) => c?.$serializeMethod())';
        }
      }

      // Iterable<OfflineFirstModel>, Iterable<Future<OfflineFirstModel>>
      if (checker.isArgTypeASibling) {
        if (offlineFirstAnnotation.where != null) {
          final awaited = checker.isArgTypeAFuture ? 'async => (await s)' : '=> s';
          final pair = offlineFirstAnnotation.where.entries.first;
          final instanceWithField = wrappedInFuture ? '(await $fieldValue)' : '$fieldValue';
          return '$instanceWithField?.map((s) $awaited.${pair.key})';
        }

        final awaited = checker.isArgTypeAFuture ? 'async' : '';
        final awaitedValue = checker.isArgTypeAFuture ? '(await s)' : 's';
        return '''await Future.wait<Map<String, dynamic>>(
          $fieldValue?.map((s) $awaited =>
            ${checker.unFuturedArgType}Adapter().toRest($awaitedValue)
          )?.toList() ?? []
        )''';
      }

      return '$fieldValue';

      // OfflineFirstModel, Future<OfflineFirstModel>
    } else if (checker.isSibling) {
      final wrappedField = wrappedInFuture ? '(await $fieldValue)' : '$fieldValue';
      if (offlineFirstAnnotation.where != null) {
        final pair = offlineFirstAnnotation.where.entries.first;
        return '$wrappedField?.${pair.key}';
      } else {
        return 'await ${checker.unFuturedType}Adapter().toRest($wrappedField ?? {})';
      }

      // enum
    } else if (checker.isEnum) {
      if (fieldAnnotation.enumAsString) {
        return "$fieldValue?.toString()?.split('.')?.last";
      } else {
        return '$fieldValue != null ? ${field.type}.values.indexOf($fieldValue) : null';
      }

      // serializable non-adapter OfflineFirstModel
    } else if (checker.hasSerdes) {
      final _hasSerializer = hasSerializer(field.type);
      if (_hasSerializer) {
        return '$fieldValue?.$serializeMethod()';
      }
    }

    return null;
  }
}
