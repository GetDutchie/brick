import 'package:analyzer/dart/element/element.dart' show ClassElement;
import 'package:brick_sqlite_abstract/sqlite_model.dart';
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;
import 'package:brick_sqlite_abstract/db.dart' show InsertTable, InsertForeignKey;
import 'package:brick_sqlite_generators/src/sqlite_serdes_generator.dart';
import 'package:brick_build/generators.dart' show SerdesGenerator, SharedChecker;

import 'sqlite_fields.dart';

/// Generate a function to produce a [ClassElement] from SQLite data
class SqliteDeserialize<_Model extends SqliteModel> extends SqliteSerdesGenerator<_Model> {
  SqliteDeserialize(
    ClassElement element,
    SqliteFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final doesDeserialize = true;

  @override
  final generateSuffix =
      "..${InsertTable.PRIMARY_KEY_FIELD} = data['${InsertTable.PRIMARY_KEY_COLUMN}'] as int;";

  @override
  String deserializerNullableClause({required field, required fieldAnnotation, required name}) {
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
  String? coderForField(field, checker, {required wrappedInFuture, required fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);
    final defaultValue = SerdesGenerator.defaultValueSuffix(fieldAnnotation);
    if (field.name == InsertTable.PRIMARY_KEY_FIELD) {
      throw InvalidGenerationSourceError(
        'Field `${InsertTable.PRIMARY_KEY_FIELD}` conflicts with reserved `SqliteModel` getter.',
        todo: 'Rename the field from `${InsertTable.PRIMARY_KEY_FIELD}`',
        element: field,
      );
    }

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
        forceCast: !checker.isArgTypeASibling,
      );

      if (checker.isArgTypeASibling) {
        final awaited = wrappedInFuture ? 'async => await' : '=>';
        final query = '''
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
        return 'jsonDecode($fieldValue).map((d) => d as int > -1 ? ${SharedChecker.withoutNullability(argType)}.values[d] : null)$castIterable';
      }

      // Iterable<bool>
      if (argTypeChecker.isBool) {
        return 'jsonDecode($fieldValue).map((d) => d == 1)$castIterable';
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
      if (checker.isNullable) {
        return '($fieldValue > -1 ? ${SharedChecker.withoutNullability(field.type)}.values[$fieldValue as int] : null)$defaultValue';
      }
      return '${SharedChecker.withoutNullability(field.type)}.values[$fieldValue as int]';

      // Map
    } else if (checker.isMap) {
      return 'jsonDecode($fieldValue)';
    }

    return null;
  }
}
