import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart' show SerdesGenerator, SharedChecker;
import 'package:brick_core/src/model.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart' show InsertForeignKey, InsertTable;
import 'package:brick_sqlite_generators/src/sqlite_serdes_generator.dart';
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;

/// Generate a function to produce a [ClassElement] from SQLite data
class SqliteDeserialize<_Model extends SqliteModel> extends SqliteSerdesGenerator<_Model> {
  /// Generate a function to produce a [ClassElement] from SQLite data
  SqliteDeserialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });

  @override
  final doesDeserialize = true;

  @override
  final generateSuffix =
      "..${InsertTable.PRIMARY_KEY_FIELD} = data['${InsertTable.PRIMARY_KEY_COLUMN}'] as int;";

  @override
  String deserializerNullableClause({
    required FieldElement field,
    required Sqlite fieldAnnotation,
    required String name,
  }) {
    final checker = checkerForType(field.type);
    if (checker.isIterable && checker.isArgTypeASibling) {
      return '';
    }

    return super.deserializerNullableClause(
      field: field,
      fieldAnnotation: fieldAnnotation,
      name: name,
    );
  }

  @override
  String? coderForField(
    FieldElement field,
    SharedChecker<Model> checker, {
    required bool wrappedInFuture,
    required Sqlite fieldAnnotation,
  }) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);
    final defaultValue = SerdesGenerator.defaultValueSuffix(fieldAnnotation);
    if (field.name == InsertTable.PRIMARY_KEY_FIELD) {
      throw InvalidGenerationSourceError(
        'Field `${InsertTable.PRIMARY_KEY_FIELD}` conflicts with reserved `SqliteModel` getter.',
        todo: 'Rename the field from `${InsertTable.PRIMARY_KEY_FIELD}`',
        element: field,
      );
    }

    if (fieldAnnotation.ignoreFrom) return null;

    if (fieldAnnotation.columnType != null) {
      return fieldValue;
    }

    // DateTime
    if (checker.isDateTime) {
      if (checker.isNullable) {
        return '$fieldValue == null ? null : DateTime.tryParse($fieldValue$defaultValue as String)';
      }
      return 'DateTime.parse($fieldValue$defaultValue as String)';

      // bool
    } else if (checker.isBool) {
      return '$fieldValue == 1';

      // double, int, String
    } else if (checker.isDartCoreType) {
      return '$fieldValue as ${field.type}$defaultValue';

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = SharedChecker<SqliteModel>(checker.argType);
      final argType = checker.unFuturedArgType;
      final castIterable = SerdesGenerator.iterableCast(
        argType,
        isSet: checker.isSet,
        isList: checker.isList,
        isFuture: checker.isArgTypeAFuture,
        forceCast: true,
      );

      if (checker.isArgTypeASibling) {
        final awaited = wrappedInFuture ? 'async => await' : '=>';
        const query = '''
          Query.where('${InsertTable.PRIMARY_KEY_FIELD}', ${InsertTable.PRIMARY_KEY_FIELD}, limit1: true),
        ''';
        final argTypeAsString = SharedChecker.withoutNullability(argType);
        final sqlStatement =
            'SELECT DISTINCT `${InsertForeignKey.joinsTableForeignColumnName(argTypeAsString)}` FROM `${InsertForeignKey.joinsTableName(fieldAnnotation.name!, localTableName: fields.element.name)}` WHERE ${InsertForeignKey.joinsTableLocalColumnName(fields.element.name)} = ?';

        final method = '''
          provider
            .rawQuery('$sqlStatement', [data['${InsertTable.PRIMARY_KEY_COLUMN}'] as int])
            .then((results) {
              final ids = results.map((r) => r['${InsertForeignKey.joinsTableForeignColumnName(argTypeAsString)}']);
              return Future.wait<$argType>(
                ids.map((${InsertTable.PRIMARY_KEY_FIELD}) $awaited ${getAssociationMethod(argType, query: query)})
              );
            })
        ''';

        // Future<Iterable<SqliteModel>>
        if (wrappedInFuture) {
          return method;
        }

        // Iterable<Future<SqliteModel>>
        if (checker.isArgTypeAFuture) {
          return 'await $method';

          // Iterable<SqliteModel>
        } else {
          if (checker.isSet) {
            return '(await $method).toSet()';
          }

          return '(await $method)$castIterable';
        }
      }

      // Iterable<DateTime>
      if (argTypeChecker.isDateTime) {
        return "jsonDecode($fieldValue).map((d) => DateTime.tryParse(d ?? ''))$castIterable";
      }

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        final deserializeFactory = argTypeChecker.enumDeserializeFactory(providerName);
        if (deserializeFactory != null) {
          return 'jsonDecode($fieldValue ?? []).map(${SharedChecker.withoutNullability(argType)}.$deserializeFactory)';
        }

        if (fieldAnnotation.enumAsString) {
          return 'jsonDecode($fieldValue ?? []).whereType<String>().map(${SharedChecker.withoutNullability(argType)}.values.byName)$castIterable';
        }

        final discoveredByIndex =
            'jsonDecode($fieldValue).map((d) => d as int > -1 ? ${SharedChecker.withoutNullability(argType)}.values[d] : null)';
        final nullableSuffix = checker.isNullable ? '?' : '';
        return '$discoveredByIndex$nullableSuffix.whereType<${argType.getDisplayString()}>()$castIterable';
      }

      // Iterable<bool>
      if (argTypeChecker.isBool) {
        return 'jsonDecode($fieldValue).map((d) => d == 1)$castIterable';
      }

      // Iterable<fromJson>
      if (argTypeChecker.fromJsonConstructor != null) {
        final klass = argTypeChecker.targetType.element! as ClassElement;
        final parameterType = argTypeChecker.fromJsonConstructor!.parameters.first.type;
        final nullableSuffix = checker.isNullable ? " ?? '[]'" : '';

        return '''jsonDecode($fieldValue$nullableSuffix).map(
          (d) => ${klass.displayName}.fromJson(d as ${parameterType.getDisplayString()})
        )$castIterable$defaultValue''';
      }

      // Iterable<double>, Iterable<int>, Iterable<num>, Iterable<Map>, Iterable<String>
      return 'jsonDecode($fieldValue)$castIterable';

      // SqliteModel, Future<SqliteModel>
    } else if (checker.isSibling) {
      var repositoryOperator = checker.isUnFuturedTypeNullable ? '?' : '!';
      if (repositoryHasBeenForceCast) repositoryOperator = '';
      if (repositoryOperator == '!') repositoryHasBeenForceCast = true;

      final query = '''
        Query.where('${InsertTable.PRIMARY_KEY_FIELD}', $fieldValue as int, limit1: true),
      ''';

      if (wrappedInFuture) {
        if (checker.isNullable) {
          return '''($fieldValue > -1
              ? ${getAssociationMethod(checker.unFuturedType, query: query)}
              : null)''';
        }
        return getAssociationMethod(checker.unFuturedType, query: query);
      }

      if (checker.isNullable) {
        return '''($fieldValue > -1
              ? (await repository$repositoryOperator.getAssociation<${SharedChecker.withoutNullability(checker.unFuturedType)}>($query))?.first
              : null)''';
      }
      return '(await repository$repositoryOperator.getAssociation<${SharedChecker.withoutNullability(checker.unFuturedType)}>($query))!.first';

      // enum
    } else if (checker.isEnum) {
      final deserializeFactory = checker.enumDeserializeFactory(providerName);
      if (deserializeFactory != null) {
        return '${checker.isNullable ? "$fieldValue == null ? null :" : ""} ${SharedChecker.withoutNullability(field.type)}.$deserializeFactory($fieldValue)';
      }

      if (fieldAnnotation.enumAsString) {
        final nullablePrefix = checker.isNullable
            ? "$fieldValue == null ? ${fieldAnnotation.defaultValue ?? 'null'} : "
            : '';
        return '$nullablePrefix${SharedChecker.withoutNullability(field.type)}.values.byName($fieldValue as String)';
      }

      if (checker.isNullable) {
        return '($fieldValue > -1 ? ${SharedChecker.withoutNullability(field.type)}.values[$fieldValue as int] : null)$defaultValue';
      }
      return '${SharedChecker.withoutNullability(field.type)}.values[$fieldValue as int]';

      // Map
    } else if (checker.isMap) {
      return 'jsonDecode($fieldValue)';
    } else if (checker.fromJsonConstructor != null) {
      final klass = checker.targetType.element! as ClassElement;
      final parameterType = checker.fromJsonConstructor!.parameters.first.type;
      return '${klass.displayName}.fromJson(jsonDecode($fieldValue as String) as ${parameterType.getDisplayString()})';
    }

    return null;
  }
}
