import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_checker.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_fields.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_serdes_generator.dart';
import 'package:brick_rest_build/generators.dart';

class OfflineFirstRestSerialize extends RestSerialize<OfflineFirstWithRestModel> {
  final OfflineFirstFields offlineFirstFields;
  OfflineFirstRestSerialize(ClassElement element, RestFields fields)
      : this.offlineFirstFields = OfflineFirstFields(element),
        super(element, fields, repositoryName: REPOSITORY_NAME);

  @override
  OfflineFirstChecker checkerForField(field, {type}) => checkerCallback(field, type: type);

  @override
  String coderForField(field, checker, {wrappedInFuture, fieldAnnotation}) {
    final offlineFirstAnnotation = offlineFirstFields.annotationForField(field);

    if (offlineFirstAnnotation.where != null && offlineFirstAnnotation.where.length > 1) {
      return null;
    }

    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);

    if (checker.isIterable) {
      final argTypeChecker = checkerForField(field, type: checker.argType);
      if (checker.isArgTypeASibling && offlineFirstAnnotation.where != null) {
        final awaited = checker.isArgTypeAFuture ? 'async => (await s)' : '=> s';
        final pair = offlineFirstAnnotation.where.entries.first;
        final instanceWithField = wrappedInFuture ? '(await $fieldValue)' : '$fieldValue';
        return '$instanceWithField?.map((s) $awaited.${pair.key})';
      }

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasSerializer = hasSerializer(checker.argType);
        if (_hasSerializer) {
          return '$fieldValue?.map((${checker.argType.getDisplayString()} c) => c?.$serializeMethod())';
        }
      }
    }

    if (checker.isSibling) {
      final wrappedField = wrappedInFuture ? '(await $fieldValue)' : '$fieldValue';
      if (offlineFirstAnnotation.where != null) {
        final pair = offlineFirstAnnotation.where.entries.first;
        return '$wrappedField?.${pair.key}';
      } else {
        return 'await ${checker.unFuturedType}Adapter().toRest($wrappedField ?? {})';
      }
    }

    if ((checker as OfflineFirstChecker).hasSerdes) {
      final _hasSerializer = hasSerializer(field.type);
      if (_hasSerializer) {
        return '$fieldValue?.$serializeMethod()';
      }
    }

    return super.coderForField(field, checker,
        wrappedInFuture: wrappedInFuture, fieldAnnotation: fieldAnnotation);
  }
}

class OfflineFirstRestDeserialize extends RestDeserialize {
  final OfflineFirstFields offlineFirstFields;
  OfflineFirstRestDeserialize(ClassElement element, RestFields fields)
      : this.offlineFirstFields = OfflineFirstFields(element),
        super(element, fields, repositoryName: REPOSITORY_NAME);

  @override
  OfflineFirstChecker checkerForField(field, {type}) => checkerCallback(field, type: type);

  @override
  String coderForField(field, checker, {wrappedInFuture, fieldAnnotation}) {
    final offlineFirstAnnotation = offlineFirstFields.annotationForField(field);
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
    final defaultValue = SerdesGenerator.defaultValueSuffix(fieldAnnotation);

    // Iterable
    if (checker.isIterable) {
      final argType = checker.unFuturedArgType;
      final argTypeChecker = OfflineFirstChecker(checker.argType);
      final castIterable = SerdesGenerator.iterableCast(argType,
          isSet: checker.isSet,
          isList: checker.isList,
          isFuture: wrappedInFuture || checker.isFuture);

      // Iterable<OfflineFirstModel>, Iterable<Future<OfflineFirstModel>>
      if (checker.isArgTypeASibling) {
        // @OfflineFirst(where: )
        if (offlineFirstAnnotation.where != null) {
          final where = _convertSqliteLookupToString(offlineFirstAnnotation.where);

          // Future<Iterable<OfflineFirstModel>>
          if (wrappedInFuture) {
            return '''repository
              ?.getAssociation<$argType>(Query(where: $where))''';

            // Iterable<OfflineFirstModel>
          } else {
            final fromRestCast = SerdesGenerator.iterableCast(argType,
                isSet: checker.isSet, isList: checker.isList, isFuture: true);
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
      }

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasConstructor = hasConstructor(checker.argType);
        if (_hasConstructor) {
          final serializableType = argTypeChecker.superClassTypeArgs.first.getDisplayString();
          return "$fieldValue.map((c) => ${checker.argType}.$constructorName(c as $serializableType))$castIterable$defaultValue";
        }
      }
    }

    // OfflineFirstModel(where:)
    if (checker.isSibling) {
      final shouldAwait = wrappedInFuture ? '' : 'await ';

      if (offlineFirstAnnotation.where != null) {
        final type = checker.unFuturedType;
        final where = _convertSqliteLookupToString(offlineFirstAnnotation.where);
        return '''${shouldAwait}repository
          ?.getAssociation<$type>(Query(where: $where, params: {'limit': 1}))?.then((a) => a?.isNotEmpty == true ? a.first : null)''';
      }
    }

    // serializable non-adapter OfflineFirstModel, OfflineFirstSerdes
    if ((checker as OfflineFirstChecker).hasSerdes) {
      final _hasConstructor = hasConstructor(field.type);
      if (_hasConstructor) {
        return "${field.type}.$constructorName($fieldValue)";
      }
    }

    return super.coderForField(field, checker,
        wrappedInFuture: wrappedInFuture, fieldAnnotation: fieldAnnotation);
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
