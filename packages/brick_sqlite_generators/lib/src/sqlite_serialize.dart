import 'package:meta/meta.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:brick_sqlite_abstract/db.dart' show InsertTable, InsertForeignKey;
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
      '${InsertTable.PRIMARY_KEY_FIELD}': RuntimeSqliteColumnDefinition(
        association: false,
        columnName: '${InsertTable.PRIMARY_KEY_COLUMN}',
        iterable: false,
        type: int,
      )''');

    for (var field in unignoredFields) {
      final annotation = fields.annotationForField(field);
      final checker = checkerForType(field.type);
      final columnName = providerNameForField(annotation.name, checker: checker);
      final columnInsertionType = _finalTypeForField(field.type);

      // T0D0 support List<Future<Sibling>> for 'association'
      fieldsToColumns.add('''
          '${field.name}': RuntimeSqliteColumnDefinition(
            association: ${checker.isSibling || (checker.isIterable && checker.isArgTypeASibling)},
            columnName: '$columnName',
            iterable: ${checker.isIterable},
            type: $columnInsertionType,
          )''');
      if (annotation.unique) {
        uniqueFields[field.name] = providerNameForField(annotation.name, checker: checker);
      }
    }

    final primaryKeyByUniqueColumns = generateUniqueSqliteFunction(uniqueFields);
    final afterSaveCallbacks = unignoredFields.where((f) {
      final checker = checkerForType(f.type);
      return checker.isIterable && checker.isArgTypeASibling;
    }).map(_saveIterableAssociationFieldToJoins);

    return [
      'final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {${fieldsToColumns.join(',\n')}};',
      primaryKeyByUniqueColumns,
      "final String tableName = '$tableName';",
      if (afterSaveCallbacks.isNotEmpty)
        "Future<void> afterSave(instance, {provider, repository}) async {${afterSaveCallbacks.join('\n')}}"
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

      // bool
    } else if (checker.isBool) {
      return _boolForField(fieldValue, fieldAnnotation.nullable);

      // double, int, num, String
    } else if (checker.isDartCoreType) {
      return fieldValue;

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = checkerForType(checker.argType);

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        return 'jsonEncode($fieldValue?.map((s) => ${checker.argType}.values.indexOf(s))?.toList()?.cast<int>() ?? [])';
      }

      // Iterable<Future<bool>>, Iterable<Future<DateTime>>, Iterable<Future<double>>,
      // Iterable<Future<int>>, Iterable<Future<num>>, Iterable<Future<String>>, Iterable<Future<Map>>
      if (checker.isArgTypeAFuture) {
        if (checker.isSerializable && !checker.isArgTypeASibling) {
          // Iterable<Future<bool>>
          final wrappedValue =
              checker.isBool ? _boolForField(fieldValue, fieldAnnotation.nullable) : fieldValue;

          return 'jsonEncode(await Future.wait<${argTypeChecker.unFuturedArgType}>($wrappedValue) ?? [])';
        }
      }

      // Set<any>
      // jsonEncode can't convert LinkedHashSet
      if (checker.isSet && !checker.isArgTypeASibling) {
        return 'jsonEncode($fieldValue?.toList() ?? [])';
      }

      // Iterable<bool>
      if (argTypeChecker.isBool) {
        return 'jsonEncode($fieldValue.map((b) => ${_boolForField('b', fieldAnnotation.nullable)}).toList())';
      }

      // Iterable<DateTime>, Iterable<double>, Iterable<int>, Iterable<num>, Iterable<String>, Iterable<Map>
      if (argTypeChecker.isDartCoreType || argTypeChecker.isMap) {
        return 'jsonEncode($fieldValue ?? [])';
      }
      // SqliteModel, Future<SqliteModel>
    } else if (checker.isSibling) {
      final instance = wrappedInFuture ? '(await $fieldValue)' : fieldValue;
      return '$instance?.${InsertTable.PRIMARY_KEY_FIELD} ?? await provider?.upsert<${checker.unFuturedType}>($instance, repository: repository)';

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
      return '$functionDeclaration => instance?.primaryKey;';
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

  String _saveIterableAssociationFieldToJoins(FieldElement field) {
    final annotation = fields.annotationForField(field);
    var checker = checkerForType(field.type);
    final fieldValue = serdesValueForField(field, annotation.name, checker: checker);

    final wrappedInFuture = checker.isFuture;
    if (wrappedInFuture) {
      checker = checkerForType(checker.argType);
    }

    final joinsTable =
        InsertForeignKey.joinsTableName(annotation.name, localTableName: fields.element.name);
    final joinsForeignColumn =
        InsertForeignKey.joinsTableForeignColumnName(checker.unFuturedArgType.getDisplayString());
    final joinsLocalColumn = InsertForeignKey.joinsTableLocalColumnName(fields.element.name);

    // Iterable<Future<SqliteModel>>
    final insertStatement =
        'INSERT OR IGNORE INTO `$joinsTable` (`$joinsLocalColumn`, `$joinsForeignColumn`)';
    var siblingAssociations = fieldValue;
    var upsertMethod =
        '(await s)?.${InsertTable.PRIMARY_KEY_FIELD} ?? await provider?.upsert<${checker.unFuturedArgType}>((await s), repository: repository)';

    // Iterable<SqliteModel>
    if (!checker.isArgTypeAFuture) {
      siblingAssociations = wrappedInFuture ? '(await $fieldValue)' : fieldValue;
      upsertMethod =
          's?.${InsertTable.PRIMARY_KEY_FIELD} ?? await provider?.upsert<${checker.unFuturedArgType}>(s, repository: repository)';
    }

    return '''
      if (instance.${InsertTable.PRIMARY_KEY_FIELD} != null) {
        final oldColumns = await provider?.rawQuery('SELECT `$joinsForeignColumn` FROM `$joinsTable` WHERE $joinsLocalColumn = ?', [instance.${InsertTable.PRIMARY_KEY_FIELD}]);
        final oldIds = oldColumns?.map((a) => a[$joinsForeignColumn]) ?? [];
        final newIds = $siblingAssociations?.map((s) => s?.${InsertTable.PRIMARY_KEY_FIELD})?.where((s) => s != null) ?? [];
        final idsToDelete = oldIds.where((id) => !newIds.contains(id));

        await Future.wait<int>($siblingAssociations?.map((s) async {
          final id = $upsertMethod;
          final shouldDelete = idsToDelete.contains(id);
          if (shouldDelete) {
            return await provider?.rawExecute('DELETE FROM `$joinsTable` WHERE $joinsLocalColumn = ? AND $joinsForeignColumn = ?', [instance.${InsertTable.PRIMARY_KEY_FIELD}, id]).catchError((e) => null);
          } else {
            return await provider?.rawInsert('$insertStatement VALUES (?, ?)', [instance.${InsertTable.PRIMARY_KEY_FIELD}, id]);
          }
        }) ?? []);
      }
    ''';
  }

  String _finalTypeForField(DartType type) {
    final checker = checkerForType(type);
    // Future<?>, Iterable<?>
    if (checker.isFuture || checker.isIterable) {
      return _finalTypeForField(checker.argType);
    }

    // remove arg types as they can't be declared in final fields
    return type.getDisplayString().replaceAll(RegExp(r'\<[,\s\w]+\>'), '');
  }

  String _boolForField(String fieldValue, bool nullable) {
    final convertToInt = '$fieldValue ? 1 : 0';
    if (nullable) {
      return '$fieldValue == null ? null : ($convertToInt)';
    }

    return convertToInt;
  }
}
