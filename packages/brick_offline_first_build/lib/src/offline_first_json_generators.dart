import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/core.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:brick_json_generators/json_deserialize.dart';
import 'package:brick_json_generators/json_serialize.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';

/// Adds support for siblings and serdes.
/// It's best to extend the original generator
/// (e.g. `class OfflineFirstRestSerialize extends RestSerialize with OfflineFirstJsonSerialize`)
mixin OfflineFirstJsonSerialize<TModel extends Model, Annotation extends FieldSerializable>
    on JsonSerialize<TModel, Annotation> {
  ///
  OfflineFirstFields get offlineFirstFields;

  @override
  OfflineFirstChecker checkerForType(DartType type) => OfflineFirstChecker(type);

  @override
  List<String> get instanceFieldsAndMethods {
    final fieldsToColumns = unignoredFields.fold<List<String>>([], (acc, field) {
      final offlineFirstAnnotation = offlineFirstFields.annotationForField(field);
      final where =
          offlineFirstAnnotation.where?.entries.fold<List<String>>(<String>[], (acc, entry) {
        if (entry.value.contains("'")) {
          acc.add("'${entry.key}': \"${entry.value}\"");
        } else {
          acc.add("'${entry.key}': '${entry.value}'");
        }
        return acc;
      }).join(',');

      if (where != null && where.isNotEmpty) {
        final output = '''
          '${field.name}': const RuntimeOfflineFirstDefinition(
            where: <String, String>{$where},
          )
        ''';
        acc.add(output);
      }
      return acc;
    });

    return [
      if (fieldsToColumns.isNotEmpty)
        '@override\nfinal fieldsToOfflineFirstRuntimeDefinition = <String, RuntimeOfflineFirstDefinition>{${fieldsToColumns.join(',\n')}};',
      ...super.instanceFieldsAndMethods,
    ];
  }

  @override
  String? coderForField(
    FieldElement field,
    SharedChecker<Model> checker, {
    required bool wrappedInFuture,
    required Annotation fieldAnnotation,
  }) {
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
        final doesHaveSerializer = hasSerializer(checker.argType);
        if (doesHaveSerializer) {
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
        final graphqlSerializerStatement =
            'await ${SharedChecker.withoutNullability(checker.unFuturedType)}Adapter().to$providerName($wrappedField$nullableSuffix, provider: provider, repository: repository)';
        if (checker.isUnFuturedTypeNullable) {
          return '$wrappedField != null ? $graphqlSerializerStatement : null';
        }

        return graphqlSerializerStatement;
      }
    }

    if ((checker as OfflineFirstChecker).hasSerdes) {
      final doesHaveSerializer = hasSerializer(field.type);
      if (doesHaveSerializer) {
        final nullableSuffix = checker.isNullable ? '?' : '';
        return '$fieldValue$nullableSuffix.$serializeMethod()';
      }
    }

    return super.coderForField(
      field,
      checker,
      wrappedInFuture: wrappedInFuture,
      fieldAnnotation: fieldAnnotation,
    );
  }
}

/// Adds support for siblings and serdes.
/// It's best to extend the original generator
/// (e.g. `class OfflineFirstRestDeserialize extends RestDeserialize with OfflineFirstJsonDeserialize`)
mixin OfflineFirstJsonDeserialize<TModel extends Model, Annotation extends FieldSerializable>
    on JsonDeserialize<TModel, Annotation> {
  ///
  OfflineFirstFields get offlineFirstFields;

  @override
  OfflineFirstChecker checkerForType(DartType type) => OfflineFirstChecker(type);

  @override
  String? coderForField(
    FieldElement field,
    SharedChecker<Model> checker, {
    required bool wrappedInFuture,
    required Annotation fieldAnnotation,
  }) {
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
        if (offlineFirstAnnotation.where != null &&
            offlineFirstAnnotation.applyToRemoteDeserialization) {
          final where = _convertSqliteLookupToString(offlineFirstAnnotation.where!);

          // Future<Iterable<OfflineFirstModel>>
          if (wrappedInFuture) {
            return '''repository
              $repositoryOperator.getAssociation<${SharedChecker.withoutNullability(argType)}>(Query(where: $where))''';

            // Iterable<OfflineFirstModel>
          } else {
            final fromJsonCast = SerdesGenerator.iterableCast(
              argType,
              isSet: checker.isSet,
              isList: checker.isList,
              isFuture: true,
            );
            final where =
                _convertSqliteLookupToString(offlineFirstAnnotation.where!, iterableArgument: 's');
            final getAssociationText = getAssociationMethod(argType, query: 'Query(where: $where)');

            if (checker.isArgTypeAFuture) {
              return '($fieldValue ?? []).map<Future<$argType>>((s) => $getAssociationText)$fromJsonCast';
            }

            final getAssociationTextForceNullable =
                getAssociationMethod(argType, query: 'Query(where: $where)', forceNullable: true);
            final getAssociations =
                '''($fieldValue ?? []).map<Future<$argType?>>((s) => $getAssociationTextForceNullable)''';
            final awaitGetAssociations =
                '(await Future.wait<$argType?>($getAssociations)).whereType<$argType>()$fromJsonCast';

            if (checker.isSet) {
              return '$awaitGetAssociations.toSet()';
            }

            return awaitGetAssociations;
          }
        }
      }

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final doesHaveConstructor = hasConstructor(checker.argType);
        if (doesHaveConstructor) {
          final serializableType = argTypeChecker.superClassTypeArgs.first.getDisplayString();
          final nullabilityOperator = checker.isNullable ? '?' : '';
          return '$fieldValue$nullabilityOperator.map((c) => ${SharedChecker.withoutNullability(checker.argType)}.$constructorName(c as $serializableType))$castIterable$defaultValue';
        }
      }
    }

    // OfflineFirstModel(where:)
    if (checker.isSibling) {
      final shouldAwait = wrappedInFuture ? '' : 'await ';

      if (offlineFirstAnnotation.where != null &&
          offlineFirstAnnotation.applyToRemoteDeserialization) {
        final type = checker.unFuturedType;
        final where = _convertSqliteLookupToString(offlineFirstAnnotation.where!);
        final getAssociationStatement =
            getAssociationMethod(type, query: 'Query(where: $where, limit: 1)');
        final isNullable = type.nullabilitySuffix != NullabilitySuffix.none;
        if (!isNullable) repositoryHasBeenForceCast = true;

        return '$shouldAwait$getAssociationStatement';
      }
    }

    // serializable non-adapter OfflineFirstModel, OfflineFirstSerdes
    if ((checker as OfflineFirstChecker).hasSerdes) {
      final doesHaveConstructor = hasConstructor(field.type);
      if (doesHaveConstructor) {
        return '${SharedChecker.withoutNullability(field.type)}.$constructorName($fieldValue)';
      }
    }

    return super.coderForField(
      field,
      checker,
      wrappedInFuture: wrappedInFuture,
      fieldAnnotation: fieldAnnotation,
    );
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
