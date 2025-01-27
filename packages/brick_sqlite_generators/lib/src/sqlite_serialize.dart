import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/src/model.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart' show InsertForeignKey, InsertTable;
import 'package:brick_sqlite_generators/src/sqlite_serdes_generator.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;

/// Generate a function to produce a [ClassElement] to SQLite data
class SqliteSerialize<_Model extends SqliteModel> extends SqliteSerdesGenerator<_Model> {
  /// Generate a function to produce a [ClassElement] to SQLite data
  SqliteSerialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });

  @override
  final doesDeserialize = false;

  ///
  String get tableName => element.name;

  @override
  List<String> get instanceFieldsAndMethods {
    final fieldsToColumns = <String>[];
    final uniqueFields = <String, String>{};

    fieldsToColumns.add('''
      '${InsertTable.PRIMARY_KEY_FIELD}': const RuntimeSqliteColumnDefinition(
        association: false,
        columnName: '${InsertTable.PRIMARY_KEY_COLUMN}',
        iterable: false,
        type: int,
      )''');

    for (final field in unignoredFields) {
      final annotation = fields.annotationForField(field);
      final checker = checkerForType(field.type);
      final columnName = providerNameForField(annotation.name, checker: checker);
      final columnInsertionType = checker.withoutNullResultType;

      // T0D0 support List<Future<Sibling>> for 'association'
      fieldsToColumns.add('''
          '${field.name}': const RuntimeSqliteColumnDefinition(
            association: ${checker.isSibling || (checker.isIterable && checker.isArgTypeASibling)},
            columnName: '$columnName',
            iterable: ${checker.isIterable},
            type: $columnInsertionType,
          )''');
      if (annotation.unique) {
        final value = uniqueValueForField(field.name, checker: checker);
        uniqueFields[value] = columnName;
      }
    }

    final primaryKeyByUniqueColumns = generateUniqueSqliteFunction(uniqueFields);
    final afterSaveCallbacks = unignoredFields.where((f) {
      final checker = checkerForType(f.type);
      return checker.isIterable && checker.isArgTypeASibling;
    }).map(_saveIterableAssociationFieldToJoins);

    return [
      '@override\nfinal Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {${fieldsToColumns.join(',\n')}};',
      primaryKeyByUniqueColumns,
      "@override\nfinal String tableName = '$tableName';",
      if (afterSaveCallbacks.isNotEmpty)
        "@override\nFuture<void> afterSave(instance, {required provider, repository}) async {${afterSaveCallbacks.join('\n')}}",
    ];
  }

  @override
  String? coderForField(
    FieldElement field,
    SharedChecker<Model> checker, {
    required bool wrappedInFuture,
    required Sqlite fieldAnnotation,
  }) {
    final name = providerNameForField(fieldAnnotation.name, checker: checker);
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);
    if (name == InsertTable.PRIMARY_KEY_COLUMN) {
      throw InvalidGenerationSourceError(
        'Field named `${InsertTable.PRIMARY_KEY_COLUMN}` conflicts with primary key',
        todo: 'Rename the field from ${InsertTable.PRIMARY_KEY_COLUMN}',
        element: field,
      );
    }

    if (fieldAnnotation.ignoreTo) return null;

    if (fieldAnnotation.columnType != null) {
      return fieldValue;
    }

    // DateTime
    if (checker.isDateTime) {
      final nullableSuffix = checker.isNullable ? '?' : '';
      return '$fieldValue$nullableSuffix.toIso8601String()';

      // bool
    } else if (checker.isBool) {
      return _boolForField(fieldValue, checker.isNullable);

      // double, int, num, String
    } else if (checker.isDartCoreType) {
      return fieldValue;

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = checkerForType(checker.argType);

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        final nullablePrefix = checker.isNullable ? '?' : '';
        final nullableDefault = checker.isNullable ? ' ?? []' : '';
        final serializeMethod = argTypeChecker.enumSerializeMethod(providerName);
        final serializedValue = serializeMethod != null
            ? 's.$serializeMethod()'
            : fieldAnnotation.enumAsString
                ? 's.name'
                : '${SharedChecker.withoutNullability(checker.argType)}.values.indexOf(s)';

        return '''
          jsonEncode($fieldValue$nullablePrefix.map((s) =>
            $serializedValue
          ).toList()$nullableDefault)
        ''';
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
        return checker.isNullable
            ? '$fieldValue == null ? null : jsonEncode($fieldValue.toList())'
            : 'jsonEncode($fieldValue.toList())';
      }

      // Iterable<bool>
      if (argTypeChecker.isBool) {
        return 'jsonEncode($fieldValue.map((b) => ${_boolForField('b', fieldAnnotation.nullable)}).toList())';
      }

      // Iterable<DateTime>, Iterable<double>, Iterable<int>, Iterable<num>, Iterable<String>, Iterable<Map>
      if (argTypeChecker.isDartCoreType || argTypeChecker.isMap) {
        return checker.isNullable
            ? '$fieldValue == null ? null : jsonEncode($fieldValue)'
            : 'jsonEncode($fieldValue)';
      }

      // Iterable<toJson>
      if (argTypeChecker.toJsonMethod != null) {
        final serializedValue = 'jsonEncode($fieldValue)';
        return checker.isNullable
            ? '$fieldValue != null ? $serializedValue : null'
            : serializedValue;
      }

      // SqliteModel, Future<SqliteModel>
    } else if (checker.isSibling) {
      final instance = wrappedInFuture ? '(await $fieldValue)' : fieldValue;
      final nullabilitySuffix = checker.isUnFuturedTypeNullable || checker.isNullable ? '!' : '';
      final upsertMethod = '''
        $instance$nullabilitySuffix.${InsertTable.PRIMARY_KEY_FIELD} ??
        await provider.upsert<${SharedChecker.withoutNullability(checker.unFuturedType)}>(
          $instance$nullabilitySuffix, repository: repository
        )''';

      if (checker.isUnFuturedTypeNullable) {
        return '$instance != null ? $upsertMethod : null';
      }

      return upsertMethod;

      // enum
    } else if (checker.isEnum) {
      final nullabilitySuffix = checker.isNullable ? '?' : '';
      final serializeMethod = checker.enumSerializeMethod(providerName);
      if (serializeMethod != null) {
        return '$fieldValue$nullabilitySuffix.$serializeMethod()';
      }

      if (fieldAnnotation.enumAsString) {
        return '$fieldValue$nullabilitySuffix.name';
      }

      if (checker.isNullable) {
        return '$fieldValue != null ? ${SharedChecker.withoutNullability(field.type)}.values.indexOf($fieldValue!) : null';
      }

      return '${SharedChecker.withoutNullability(field.type)}.values.indexOf($fieldValue)';

      // Map
    } else if (checker.isMap) {
      if (checker.isNullable) {
        return '$fieldValue != null ? jsonEncode($fieldValue) : null';
      }
      return 'jsonEncode($fieldValue)';
    } else if (checker.toJsonMethod != null) {
      final nullableSuffix = checker.isNullable ? '!' : '';
      final output = 'jsonEncode($fieldValue$nullableSuffix.toJson())';
      if (checker.isNullable) {
        return '$fieldValue != null ? $output : null';
      }
      return output;
    }

    return null;
  }

  /// Generates the method `primaryKeyByUniqueColumns` for the adapter
  @protected
  @mustCallSuper
  String generateUniqueSqliteFunction(Map<String, String> uniqueFields) {
    final functionDeclaration =
        '@override\nFuture<int?> primaryKeyByUniqueColumns(${element.name} instance, DatabaseExecutor executor) async';
    final whereStatement = <String>[];
    final valuesStatement = <String>[];
    final selectStatement = <String>[];

    for (final entry in uniqueFields.entries) {
      whereStatement.add('${entry.value} = ?');
      valuesStatement.add('instance.${entry.key}');
      selectStatement.add(entry.value);
    }

    if (selectStatement.isEmpty && whereStatement.isEmpty) {
      return '$functionDeclaration => instance.primaryKey;';
    }

    return """$functionDeclaration {
      final results = await executor.rawQuery('''
        SELECT * FROM `$tableName` WHERE ${whereStatement.join(' OR ')} LIMIT 1''',
        [${valuesStatement.join(',')}]
      );

      // SQFlite returns [{}] when no results are found
      if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
        return null;
      }

      return results.first['${InsertTable.PRIMARY_KEY_COLUMN}'] as int;
    }""";
  }

  @override
  bool ignoreCoderForField(FieldElement field, Sqlite annotation, SharedChecker<Model> checker) {
    if (annotation.columnType != null) return false;
    return super.ignoreCoderForField(field, annotation, checker);
  }

  String _saveIterableAssociationFieldToJoins(FieldElement field) {
    final annotation = fields.annotationForField(field);
    var checker = checkerForType(field.type);
    final fieldValue = serdesValueForField(field, annotation.name!, checker: checker);

    final wrappedInFuture = checker.isFuture;
    if (wrappedInFuture) {
      checker = checkerForType(checker.argType);
    }

    final joinsTable =
        InsertForeignKey.joinsTableName(annotation.name!, localTableName: fields.element.name);
    final joinsForeignColumn = InsertForeignKey.joinsTableForeignColumnName(
      SharedChecker.withoutNullability(checker.unFuturedArgType),
    );
    final joinsLocalColumn = InsertForeignKey.joinsTableLocalColumnName(fields.element.name);

    // Iterable<Future<SqliteModel>>
    final insertStatement =
        'INSERT OR IGNORE INTO `$joinsTable` (`$joinsLocalColumn`, `$joinsForeignColumn`)';
    var siblingAssociations = fieldValue;
    var upsertMethod =
        '(await s).${InsertTable.PRIMARY_KEY_FIELD} ?? await provider.upsert<${SharedChecker.withoutNullability(checker.unFuturedArgType)}>((await s), repository: repository)';

    // Iterable<SqliteModel>
    if (!checker.isArgTypeAFuture) {
      siblingAssociations = wrappedInFuture ? '(await $fieldValue)' : fieldValue;
      upsertMethod =
          's.${InsertTable.PRIMARY_KEY_FIELD} ?? await provider.upsert<${SharedChecker.withoutNullability(checker.unFuturedArgType)}>(s, repository: repository)';
    }

    final removeStaleAssociations = field.isPublic
        ? _removeStaleAssociations(
            field.name,
            joinsForeignColumn,
            joinsLocalColumn,
            joinsTable,
            siblingAssociations,
            checker.isUnFuturedTypeNullable,
            checker.unFuturedArgType.nullabilitySuffix != NullabilitySuffix.none,
          )
        : '';
    final nullabilitySuffix = checker.isNullable ? '?' : '';
    final nullabilityDefault = checker.isNullable ? ' ?? []' : '';

    return '''
      if (instance.${InsertTable.PRIMARY_KEY_FIELD} != null) {
        $removeStaleAssociations
        await Future.wait<int?>($siblingAssociations$nullabilitySuffix.map((s) async {
          final id = $upsertMethod;
          return await provider.rawInsert('$insertStatement VALUES (?, ?)', [instance.${InsertTable.PRIMARY_KEY_FIELD}, id]);
        })$nullabilityDefault);
      }
    ''';
  }

  String _boolForField(String fieldValue, bool nullable) {
    if (nullable) {
      return '$fieldValue == null ? null : ($fieldValue! ? 1 : 0)';
    }

    return '$fieldValue ? 1 : 0';
  }

  /// Provides the value for the SQL lookup. Most often this is simply the field
  /// name, but more complex use cases may require a specific property to be called
  /// on the class itself.
  ///
  /// However, it is strongly, strongly discouraged to use anything more than a primitive
  /// for unique values. A complex class with multiple fields and methods will significantly
  /// confuse maintenance. A string or int or double is more than sufficient to determine
  /// a row's uniqueness.
  @protected
  String uniqueValueForField(String? fieldName, {required SharedChecker checker}) {
    return fieldName ?? '';
  }
}

String _removeStaleAssociations(
  String fieldName,
  String joinsForeignColumn,
  String joinsLocalColumn,
  String joinsTable,
  String siblingAssociations,

  /// `true` when `Iterable<Model>` is `Iterable<Model>?`
  bool nullableField,

  /// `true` when `<Model>` in `Iterable<Model>` is `Iterable<Model?>`
  bool nullableArgType,
) {
  final argTypeNullabilitySuffix = nullableArgType ? '?' : '';
  var newIdFieldsValue =
      '$siblingAssociations.map((s) => s$argTypeNullabilitySuffix.${InsertTable.PRIMARY_KEY_FIELD}).whereType<int>()';
  if (nullableField) {
    newIdFieldsValue =
        '$siblingAssociations?.map((s) => s$argTypeNullabilitySuffix.${InsertTable.PRIMARY_KEY_FIELD}).whereType<int>() ?? []';
  }

  return '''
    final ${fieldName}OldColumns = await provider.rawQuery('SELECT `$joinsForeignColumn` FROM `$joinsTable` WHERE `$joinsLocalColumn` = ?', [instance.${InsertTable.PRIMARY_KEY_FIELD}]);
    final ${fieldName}OldIds = ${fieldName}OldColumns.map((a) => a['$joinsForeignColumn']);
    final ${fieldName}NewIds = $newIdFieldsValue;
    final ${fieldName}IdsToDelete = ${fieldName}OldIds.where((id) => !${fieldName}NewIds.contains(id));

    await Future.wait<void>(${fieldName}IdsToDelete.map((id) async {
      return await provider.rawExecute('DELETE FROM `$joinsTable` WHERE `$joinsLocalColumn` = ? AND `$joinsForeignColumn` = ?', [instance.${InsertTable.PRIMARY_KEY_FIELD}, id]).catchError((e) => null);
    }));
  ''';
}
