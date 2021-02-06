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
    String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final doesDeserialize = true;

  @override
  final generateSuffix =
      "..${InsertTable.PRIMARY_KEY_FIELD} = data['${InsertTable.PRIMARY_KEY_COLUMN}'] as int;";

  @override
  String deserializerNullableClause({field, fieldAnnotation, name}) {
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
  String coderForField(field, checker, {wrappedInFuture, fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
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
      return '$fieldValue == null ? null : DateTime.tryParse($fieldValue$defaultValue as String)';

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
      final castIterable = SerdesGenerator.iterableCast(argType,
          isSet: checker.isSet, isList: checker.isList, isFuture: checker.isArgTypeAFuture);

      if (checker.isArgTypeASibling) {
        final awaited = wrappedInFuture ? 'async => await' : '=>';
        final query = '''
          Query.where('${InsertTable.PRIMARY_KEY_FIELD}', ${InsertTable.PRIMARY_KEY_FIELD}, limit1: true),
        ''';
        final sqlStatement =
            'SELECT DISTINCT `${InsertForeignKey.joinsTableForeignColumnName(argType.getDisplayString())}` FROM `${InsertForeignKey.joinsTableName(fieldAnnotation.name, localTableName: fields.element.name)}` WHERE ${InsertForeignKey.joinsTableLocalColumnName(fields.element.name)} = ?';
        final method = '''
          provider
            ?.rawQuery('$sqlStatement', [data['${InsertTable.PRIMARY_KEY_COLUMN}'] as int])
            ?.then((results) {
              final ids = results.map((r) => (r ?? {})['${InsertForeignKey.joinsTableForeignColumnName(argType.getDisplayString())}']);
              return Future.wait<$argType>(
                ids.map((${InsertTable.PRIMARY_KEY_FIELD}) $awaited repository?.getAssociation<$argType>($query)
                ?.then((r) => (r?.isEmpty ?? true) ? null : r.first))
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
            return '(await $method).toSet().cast<$argType>()';
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
        return 'jsonDecode($fieldValue).map((d) => d as int > -1 ? $argType.values[d as int] : null)$castIterable';
      }

      // Iterable<bool>
      if (argTypeChecker.isBool) {
        return 'jsonDecode($fieldValue).map((d) => d == 1)$castIterable';
      }

      // Iterable<double>, Iterable<int>, Iterable<num>, Iterable<Map>, Iterable<String>
      return 'jsonDecode($fieldValue)$castIterable';

      // SqliteModel, Future<SqliteModel>
    } else if (checker.isSibling) {
      final query = '''
        Query.where('${InsertTable.PRIMARY_KEY_FIELD}', $fieldValue as int, limit1: true),
      ''';

      if (wrappedInFuture) {
        return '''($fieldValue > -1
            ? repository?.getAssociation<${checker.unFuturedType}>($query)?.then((r) => (r?.isEmpty ?? true) ? null : r.first)
            : null)''';
      }

      return '''($fieldValue > -1
            ? (await repository?.getAssociation<${checker.unFuturedType}>($query))?.first
            : null)''';

      // enum
    } else if (checker.isEnum) {
      return '($fieldValue > -1 ? ${field.type}.values[$fieldValue as int] : null)$defaultValue';

      // Map
    } else if (checker.isMap) {
      return 'jsonDecode($fieldValue)';
    }

    return null;
  }

  @override
  bool ignoreCoderForField(field, annotation, checker) {
    if (annotation.columnType != null) return false;
    return super.ignoreCoderForField(field, annotation, checker);
  }
}
