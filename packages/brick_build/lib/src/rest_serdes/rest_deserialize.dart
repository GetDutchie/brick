import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_rest/rest.dart' show Rest;
import 'package:brick_build/src/offline_first/offline_first_checker.dart';
import 'package:brick_build/src/offline_first/offline_first_serdes_generator.dart';
import 'package:brick_build/src/rest_serdes/rest_fields.dart';

/// Generate a function to produce a [ClassElement] from SQLite data
class RestDeserialize extends OfflineFirstSerdesGenerator<Rest> {
  RestDeserialize(
    ClassElement element,
    RestFields fields, {
    String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final providerName = OfflineFirstSerdesGenerator.REST_PROVIDER_NAME;

  @override
  final doesDeserialize = true;

  @override
  String get adapterMethod => '''await $serializingFunctionName(
    input, provider: provider, repository: repository
  )''';

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
  String coderForField(field, checker, {offlineFirstAnnotation, wrappedInFuture, fieldAnnotation}) {
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
      final argTypeChecker = OfflineFirstChecker(checker.argType);
      final castIterable = SerdesGenerator.iterableCast(argType,
          isSet: checker.isSet,
          isList: checker.isList,
          isFuture: wrappedInFuture || checker.isFuture);

      // Iterable<OfflineFirstModel>, Iterable<Future<OfflineFirstModel>>
      if (checker.isArgTypeASibling) {
        final fromRestCast = SerdesGenerator.iterableCast(argType,
            isSet: checker.isSet, isList: checker.isList, isFuture: true);

        // @OfflineFirst(where: )
        if (offlineFirstAnnotation.where != null) {
          final where = _convertSqliteLookupToString(offlineFirstAnnotation.where);

          // Future<Iterable<OfflineFirstModel>>
          if (wrappedInFuture) {
            return '''repository
              ?.getAssociation<$argType>(Query(where: $where))''';

            // Iterable<OfflineFirstModel>
          } else {
            final where =
                _convertSqliteLookupToString(offlineFirstAnnotation.where, iterableArgument: 's');
            final getAssociations = '''($fieldValue ?? []).map((s) => repository
              ?.getAssociation<$argType>(Query(where: $where))
              ?.then((a) => a?.isNotEmpty == true ? a.first : null)
            )$fromRestCast''';

            if (checker.isArgTypeAFuture) {
              return getAssociations;
            }

            if (checker.isSet) {
              return '(await Future.wait<$argType>($getAssociations ?? [])).toSet()';
            }

            return 'await Future.wait<$argType>($getAssociations ?? [])';
          }
        }

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
          return "$fieldValue.map((e) => $argType.values.indexOf(e))$castIterable$defaultValue";
        }
      }

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasConstructor = hasConstructor(checker.argType);
        if (_hasConstructor) {
          final serializableType = argTypeChecker.superClassTypeArgs.first.getDisplayString();
          return "$fieldValue.map((c) => ${checker.argType}.$constructorName(c as $serializableType))$castIterable$defaultValue";
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

      // OfflineFirstModel
    } else if (checker.isSibling) {
      final shouldAwait = wrappedInFuture ? '' : 'await ';

      if (offlineFirstAnnotation.where != null) {
        final type = checker.unFuturedType;
        final where = _convertSqliteLookupToString(offlineFirstAnnotation.where);
        return '''${shouldAwait}repository
          ?.getAssociation<$type>(Query(where: $where, params: {'limit': 1}))?.then((a) => a?.isNotEmpty == true ? a.first : null)''';
      } else {
        return '''$shouldAwait${checker.unFuturedType}Adapter().fromRest(
          $fieldValue, provider: provider, repository: repository
        )''';
      }

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

      // serializable non-adapter OfflineFirstModel, OfflineFirstSerdes
    } else if (checker.hasSerdes) {
      final _hasConstructor = hasConstructor(field.type);
      if (_hasConstructor) {
        return "${field.type}.$constructorName($fieldValue)";
      }
    }

    return null;
  }

  /// Define [iterableArgument] to condition value with one that comes from an iterated result
  String _convertSqliteLookupToString(Map<String, String> lookup, {String iterableArgument}) {
    final conditions = lookup.entries.fold<Set<String>>(<String>{}, (acc, pair) {
      final matchedValue = iterableArgument ?? pair.value;
      acc.add("Where.exact('${pair.key}', $matchedValue)");
      return acc;
    }).join(',\n');
    return '[$conditions]';
  }
}
