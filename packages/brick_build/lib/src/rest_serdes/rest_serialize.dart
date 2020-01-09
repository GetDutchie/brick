import 'package:analyzer/dart/element/element.dart';
import 'package:brick_offline_first_abstract/annotations.dart';
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

  final providerName = OfflineFirstSerdesGenerator.REST_PROVIDER_NAME;
  final doesDeserialize = false;
  String get adapterMethod =>
      "await $serializingFunctionName(input, provider: provider, repository: repository)";
  List<String> get instanceFieldsAndMethods {
    String toKey = (fields as RestFields).config?.toKey?.trim();

    if (toKey != null) toKey = '"$toKey"';

    return ['final String toKey = $toKey;'];
  }

  coderForField({checker, offlineFirstAnnotation, wrappedInFuture, field, fieldAnnotation}) {
    if (fieldAnnotation.ignoreTo) return null;

    if (fieldAnnotation?.toGenerator != null) {
      final name = serializedFieldName(checker, fieldAnnotation.name);
      final custom = digestPlaceholders(fieldAnnotation.toGenerator, name, field.name);
      return "${custom}";
    }

    if (offlineFirstAnnotation.where != null && offlineFirstAnnotation.where.length > 1) {
      return null;
    }

    // DateTime
    if (checker.isDateTime) {
      return "instance.${field.name}?.toIso8601String()";

      // bool, double, int, num, String, Map, Iterable, enum
    } else if ((checker.isDartCoreType) || checker.isMap) {
      return "instance.${field.name}";

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = OfflineFirstChecker(checker.argType);

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        if (fieldAnnotation.enumAsString) {
          return "instance.${field.name}?.map((e) => e.toString().split('.').last)";
        } else {
          return "instance.${field.name}?.map((e) => ${checker.argType.name}.values.indexOf(e))";
        }
      }

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasSerializer = hasSerializer(checker.argType);
        if (_hasSerializer) {
          return "instance.${field.name}?.map((${checker.argType.name} c) => c?.$serializeMethod())";
        }
      }

      // Iterable<OfflineFirstModel>, Iterable<Future<OfflineFirstModel>>
      if (checker.isArgTypeASibling) {
        if (offlineFirstAnnotation.where != null) {
          final awaited = checker.isArgTypeAFuture ? "async => (await s)" : "=> s";
          final pair = offlineFirstAnnotation.where.entries.first;
          final instanceWithField =
              wrappedInFuture ? "(await instance.${field.name})" : "instance.${field.name}";
          return "$instanceWithField?.map((s) $awaited.${pair.key})";
        }

        final awaited = checker.isArgTypeAFuture ? "async" : "";
        final awaitedValue = checker.isArgTypeAFuture ? "(await s)" : "s";
        return """await Future.wait<Map<String, dynamic>>(
          instance.${field.name}?.map((s) $awaited =>
            ${checker.unFuturedArgType}Adapter().toRest($awaitedValue)
          )?.toList() ?? []
        )""";
      }

      return "instance.${field.name}";

      // OfflineFirstModel, Future<OfflineFirstModel>
    } else if (checker.isSibling) {
      final wrappedField =
          wrappedInFuture ? "(await instance.${field.name})" : "instance.${field.name}";
      if (offlineFirstAnnotation.where != null) {
        final pair = offlineFirstAnnotation.where.entries.first;
        return "$wrappedField?.${pair.key}";
      } else {
        return "await ${checker.unFuturedType}Adapter().toRest($wrappedField ?? {})";
      }

      // enum
    } else if (checker.isEnum) {
      if (fieldAnnotation.enumAsString) {
        return "instance.${field.name}?.toString()?.split('.')?.last";
      } else {
        return "instance.${field.name} != null ? ${field.type}.values.indexOf(instance.${field.name}) : null";
      }

      // serializable non-adapter OfflineFirstModel
    } else if (checker.hasSerdes) {
      final _hasSerializer = hasSerializer(field.type);
      if (_hasSerializer) {
        return "instance.${field.name}?.$serializeMethod()";
      }
    }

    return null;
  }
}
