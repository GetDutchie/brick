import 'package:meta/meta.dart';
import 'package:analyzer/dart/element/element.dart' show ClassElement;
import 'package:analyzer/dart/element/type.dart' show DartType;
import 'package:brick_sqlite_abstract/db.dart' show InsertTable;
import 'package:brick_sqlite_abstract/sqlite_model.dart';
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;
import 'package:brick_sqlite_generators/src/sqlite_serdes_generator.dart';

import 'sqlite_fields.dart';

/// Generate a function to produce a [ClassElement] to SQLite data
class SqliteSerialize<_Model extends SqliteModel> extends SqliteSerdesGenerator<_Model> {
  SqliteSerialize(
    ClassElement element,
    SqliteFields fields, {
    String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final doesDeserialize = false;

  String get tableName => element.name;

  @override
  List<String> get instanceFieldsAndMethods {
    final fieldsToColumns = <String>[];
    final uniqueFields = <String, String>{};

    fieldsToColumns.add('''
      '${InsertTable.PRIMARY_KEY_FIELD}': {
        'name': '${InsertTable.PRIMARY_KEY_COLUMN}',
        'type': int,
        'iterable': false,
        'association': false,
      }''');

    for (var field in unignoredFields) {
      final annotation = fields.annotationForField(field);
      final checker = checkerForType(field.type);
      final columnName = providerNameForField(annotation.name, checker: checker);
      final columnInsertionType = _finalTypeForField(field.type);

      // T0D0 support List<Future<Sibling>> for 'association'
      fieldsToColumns.add('''
          '${field.name}': {
            'name': '$columnName',
            'type': $columnInsertionType,
            'iterable': ${checker.isIterable},
            'association': ${checker.isSibling || (checker.isIterable && checker.isArgTypeASibling)},
          }''');
      if (annotation.unique) {
        uniqueFields[field.name] = providerNameForField(annotation.name, checker: checker);
      }
    }

    final primaryKeyByUniqueColumns = generateUniqueSqliteFunction(uniqueFields);

    return [
      'final Map<String, Map<String, dynamic>> fieldsToSqliteColumns = {${fieldsToColumns.join(',\n')}};',
      primaryKeyByUniqueColumns,
      "final String tableName = '$tableName';"
    ];
  }

  @override
  String coderForField(field, checker, {wrappedInFuture, fieldAnnotation}) {
    final name = providerNameForField(fieldAnnotation.name, checker: checker);
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
    if (name == InsertTable.PRIMARY_KEY_COLUMN) {
      throw InvalidGenerationSourceError(
        'Field named `${InsertTable.PRIMARY_KEY_COLUMN}` conflicts with primary key',
        todo: 'Rename the field from ${InsertTable.PRIMARY_KEY_COLUMN}',
        element: field,
      );
    }

    // DateTime
    if (checker.isDateTime) {
      return '$fieldValue?.toIso8601String()';

      // bool, double, int, num, String
    } else if (checker.isDartCoreType) {
      return fieldValue;

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = checkerForType(checker.argType);

      if (checker.isArgTypeASibling) {
        // Iterable<Future<SqliteModel>>
        if (checker.isArgTypeAFuture) {
          return '''jsonEncode(
            (await Future.wait<int>($fieldValue
              ?.map(
                (s) async => (await s)?.${InsertTable.PRIMARY_KEY_FIELD} ?? await provider?.upsert<${checker.unFuturedArgType}>((await s), repository: repository)
              )
              ?.toList()
              ?.cast<Future<int>>()
              ?? []
            )).where((s) => s != null).toList().cast<int>()
          )''';

          // Iterable<SqliteModel>
        } else {
          final instanceAndField = wrappedInFuture ? '(await $fieldValue)' : fieldValue;

          return '''jsonEncode(
            (await Future.wait<int>($instanceAndField
              ?.map((s) async {
                return s?.${InsertTable.PRIMARY_KEY_FIELD} ?? await provider?.upsert<${checker.unFuturedArgType}>(s, repository: repository);
              })
              ?.toList()
              ?.cast<Future<int>>()
              ?? []
            )).where((s) => s != null).toList().cast<int>()
          )''';
        }
      }

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        return 'jsonEncode($fieldValue?.map((s) => ${checker.argType}.values.indexOf(s))?.toList()?.cast<int>() ?? [])';
      }

      // Iterable<Future<bool>>, Iterable<Future<DateTime>>, Iterable<Future<double>>,
      // Iterable<Future<int>>, Iterable<Future<num>>, Iterable<Future<String>>, Iterable<Future<Map>>
      if (checker.isArgTypeAFuture) {
        if (checker.isSerializable) {
          return 'jsonEncode(await Future.wait<${argTypeChecker.unFuturedArgType}>($fieldValue) ?? [])';
        }
      }

      // Iterable<bool>, Iterable<DateTime>, Iterable<double>, Iterable<int>, Iterable<num>, Iterable<String>, Iterable<Map>
      if (argTypeChecker.isDartCoreType || argTypeChecker.isMap) {
        return 'jsonEncode($fieldValue ?? [])';
      }
      // SqliteModel, Future<SqliteModel>
    } else if (checker.isSibling) {
      final instance = wrappedInFuture ? '(await $fieldValue)' : fieldValue;
      return '$instance?.${InsertTable.PRIMARY_KEY_FIELD}';

      // enum
    } else if (checker.isEnum) {
      return '${field.type}.values.indexOf($fieldValue)';

      // Map
    } else if (checker.isMap) {
      return 'jsonEncode($fieldValue ?? {})';
    }

    return null;
  }

  /// Generates the method `primaryKeyByUniqueColumns` for the adapter
  @protected
  @mustCallSuper
  String generateUniqueSqliteFunction(Map<String, String> uniqueFields) {
    final functionDeclaration =
        'Future<int> primaryKeyByUniqueColumns(${element.name} instance, DatabaseExecutor executor) async';
    final whereStatement = <String>[];
    final valuesStatement = <String>[];
    final selectStatement = <String>[];

    for (var entry in uniqueFields.entries) {
      whereStatement.add('${entry.value} = ?');
      valuesStatement.add('instance.${entry.key}');
      selectStatement.add(entry.value);
    }

    if (selectStatement.isEmpty && whereStatement.isEmpty) {
      return '$functionDeclaration => null;';
    }

    return """$functionDeclaration {
      final results = await executor.rawQuery('''
        SELECT * FROM `$tableName` WHERE ${whereStatement.join(' OR ')} LIMIT 1''',
        [${valuesStatement.join(',')}]
      );

      // SQFlite returns [{}] when no results are found
      if (results?.isEmpty == true || (results?.length == 1 && results?.first?.isEmpty == true)) return null;

      return results.first['${InsertTable.PRIMARY_KEY_COLUMN}'];
    }""";
  }

  String _finalTypeForField(DartType type) {
    final checker = checkerForType(type);
    // Future<?>, Iterable<?>
    if (checker.isFuture || checker.isIterable) {
      return _finalTypeForField(checker.argType);
    }

    if (checker.isMap) {
      // remove arg types as they can't be declared in final fields
      return "Map";
    }

    return type.getDisplayString();
  }
}
