import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_rest_generators/generators.dart';
import 'package:brick_rest_generators/rest_model_serdes_generator.dart';
import 'package:source_gen/source_gen.dart';

class _OfflineFirstRestSerialize extends RestSerialize {
  final OfflineFirstFields offlineFirstFields;
  _OfflineFirstRestSerialize(ClassElement element, RestFields fields,
      {required String repositoryName})
      : offlineFirstFields = OfflineFirstFields(element),
        super(element, fields, repositoryName: repositoryName);

  @override
  OfflineFirstChecker checkerForType(type) => OfflineFirstChecker(type);

  @override
  String? coderForField(field, checker, {required wrappedInFuture, required fieldAnnotation}) {
    final offlineFirstAnnotation = offlineFirstFields.annotationForField(field);

    if (offlineFirstAnnotation.where != null && offlineFirstAnnotation.where!.length > 1) {
      return null;
    }

    if (fieldAnnotation.ignoreTo) return null;

    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);

    if (checker.isIterable) {
      final argTypeChecker = checkerForType(checker.argType);
      if (checker.isArgTypeASibling && offlineFirstAnnotation.where != null) {
        final awaited = checker.isArgTypeAFuture ? 'async => (await s)' : '=> s';
        final pair = offlineFirstAnnotation.where!.entries.first;
        final instanceWithField = wrappedInFuture ? '(await $fieldValue)' : fieldValue;
        final nullableSuffix = checker.isNullable ? '?' : '';
        return '$instanceWithField$nullableSuffix.map((s) $awaited.${pair.key}).toList()';
      }

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasSerializer = hasSerializer(checker.argType);
        if (_hasSerializer) {
          final nullableSuffix = checker.isNullable ? '?' : '';
          return '$fieldValue$nullableSuffix.map((${SharedChecker.withoutNullability(checker.argType)} c) => c.$serializeMethod()).toList()';
        }
      }
    }

    if (checker.isSibling) {
      final wrappedField = wrappedInFuture ? '(await $fieldValue)' : fieldValue;
      if (offlineFirstAnnotation.where != null) {
        final pair = offlineFirstAnnotation.where!.entries.first;
        final nullableSuffix = checker.isNullable ? '?' : '';
        return '$wrappedField$nullableSuffix.${pair.key}';
      } else {
        final parentFieldIsNullable =
            wrappedInFuture && field.type.nullabilitySuffix != NullabilitySuffix.none;
        final nullableSuffix = parentFieldIsNullable || checker.isNullable ? '!' : '';
        final restSerializerStatement =
            'await ${SharedChecker.withoutNullability(checker.unFuturedType)}Adapter().toRest($wrappedField$nullableSuffix, provider: provider, repository: repository)';
        if (checker.isUnFuturedTypeNullable) {
          return '$wrappedField != null ? $restSerializerStatement : null';
        }

        return restSerializerStatement;
      }
    }

    if ((checker as OfflineFirstChecker).hasSerdes) {
      final _hasSerializer = hasSerializer(field.type);
      if (_hasSerializer) {
        final nullableSuffix = checker.isNullable ? '?' : '';
        return '$fieldValue$nullableSuffix.$serializeMethod()';
      }
    }

    return super.coderForField(field, checker,
        wrappedInFuture: wrappedInFuture, fieldAnnotation: fieldAnnotation);
  }
}

class _OfflineFirstRestDeserialize extends RestDeserialize {
  final OfflineFirstFields offlineFirstFields;
  _OfflineFirstRestDeserialize(ClassElement element, RestFields fields,
      {required String repositoryName})
      : offlineFirstFields = OfflineFirstFields(element),
        super(element, fields, repositoryName: repositoryName);

  @override
  OfflineFirstChecker checkerForType(type) => OfflineFirstChecker(type);

  @override
  String? coderForField(field, checker, {required wrappedInFuture, required fieldAnnotation}) {
    final offlineFirstAnnotation = offlineFirstFields.annotationForField(field);
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);
    final defaultValue = SerdesGenerator.defaultValueSuffix(fieldAnnotation);

    if (fieldAnnotation.ignoreFrom) return null;

    // Iterable
    if (checker.isIterable) {
      final argType = checker.unFuturedArgType;
      final argTypeChecker = OfflineFirstChecker(checker.argType);
      final castIterable = SerdesGenerator.iterableCast(
        argType,
        isSet: checker.isSet,
        isList: checker.isList,
        isFuture: wrappedInFuture || checker.isFuture,
        forceCast: true,
      );

      // Iterable<OfflineFirstModel>, Iterable<Future<OfflineFirstModel>>
      if (checker.isArgTypeASibling) {
        final isNullable = argType.nullabilitySuffix != NullabilitySuffix.none;
        final repositoryOperator = isNullable ? '?' : '!';

        // @OfflineFirst(where: )
        if (offlineFirstAnnotation.where != null) {
          final where = _convertSqliteLookupToString(offlineFirstAnnotation.where!);

          // Future<Iterable<OfflineFirstModel>>
          if (wrappedInFuture) {
            return '''repository
              $repositoryOperator.getAssociation<${SharedChecker.withoutNullability(argType)}>(Query(where: $where))''';

            // Iterable<OfflineFirstModel>
          } else {
            final fromRestCast = SerdesGenerator.iterableCast(argType,
                isSet: checker.isSet, isList: checker.isList, isFuture: true);
            final where =
                _convertSqliteLookupToString(offlineFirstAnnotation.where!, iterableArgument: 's');
            final getAssociationText = getAssociationMethod(argType, query: 'Query(where: $where)');

            if (checker.isArgTypeAFuture) {
              return '($fieldValue ?? []).map<Future<$argType>>((s) => $getAssociationText)$fromRestCast';
            }

            final getAssociationTextForceNullable =
                getAssociationMethod(argType, query: 'Query(where: $where)', forceNullable: true);
            final getAssociations =
                '''($fieldValue ?? []).map<Future<$argType?>>((s) => $getAssociationTextForceNullable)''';
            final awaitGetAssociations =
                '(await Future.wait<$argType?>($getAssociations)).whereType<$argType>()$fromRestCast';

            if (checker.isSet) {
              return '$awaitGetAssociations.toSet()';
            }

            return awaitGetAssociations;
          }
        }
      }

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasConstructor = hasConstructor(checker.argType);
        if (_hasConstructor) {
          final serializableType =
              argTypeChecker.superClassTypeArgs.first.getDisplayString(withNullability: true);
          final nullabilityOperator = checker.isNullable ? '?' : '';
          return '$fieldValue$nullabilityOperator.map((c) => ${SharedChecker.withoutNullability(checker.argType)}.$constructorName(c as $serializableType))$castIterable$defaultValue';
        }
      }
    }

    // OfflineFirstModel(where:)
    if (checker.isSibling) {
      final shouldAwait = wrappedInFuture ? '' : 'await ';

      if (offlineFirstAnnotation.where != null) {
        final type = checker.unFuturedType;
        final where = _convertSqliteLookupToString(offlineFirstAnnotation.where!);
        final getAssociationStatement =
            getAssociationMethod(type, query: "Query(where: $where, providerArgs: {'limit': 1})");
        final isNullable = type.nullabilitySuffix != NullabilitySuffix.none;
        if (!isNullable) repositoryHasBeenForceCast = true;

        return '$shouldAwait$getAssociationStatement';
      }
    }

    // serializable non-adapter OfflineFirstModel, OfflineFirstSerdes
    if ((checker as OfflineFirstChecker).hasSerdes) {
      final _hasConstructor = hasConstructor(field.type);
      if (_hasConstructor) {
        return '${SharedChecker.withoutNullability(field.type)}.$constructorName($fieldValue)';
      }
    }

    return super.coderForField(field, checker,
        wrappedInFuture: wrappedInFuture, fieldAnnotation: fieldAnnotation);
  }

  /// Define [iterableArgument] to condition value with one that comes from an iterated result
  String _convertSqliteLookupToString(Map<String, String> lookup, {String? iterableArgument}) {
    final conditions = lookup.entries.fold<Set<String>>(<String>{}, (acc, pair) {
      final matchedValue = iterableArgument ?? pair.value;
      acc.add("Where.exact('${pair.key}', $matchedValue)");
      return acc;
    }).join(',\n');
    return '[$conditions]';
  }
}

class OfflineFirstRestModelSerdesGenerator extends RestModelSerdesGenerator {
  OfflineFirstRestModelSerdesGenerator(Element element, ConstantReader reader,
      {required String repositoryName})
      : super(element, reader, repositoryName: repositoryName);

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = RestFields(classElement, config);
    return [
      _OfflineFirstRestDeserialize(classElement, fields, repositoryName: repositoryName!),
      _OfflineFirstRestSerialize(classElement, fields, repositoryName: repositoryName!),
    ];
  }
}
