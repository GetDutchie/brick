import 'package:analyzer/dart/element/element.dart' show ClassElement;
import 'package:analyzer/dart/element/type.dart' show DartType;
import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/db.dart' show InsertTable;
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;

import '../offline_first/offline_first_checker.dart';
import '../offline_first/offline_first_serdes_generator.dart';
import 'sqlite_fields.dart';

/// Generate a function to produce a [ClassElement] from SQLite data
class SqliteSerialize extends OfflineFirstSerdesGenerator<Sqlite> {
  SqliteSerialize(
    ClassElement element,
    SqliteFields fields, {
    String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final providerName = OfflineFirstSerdesGenerator.SQLITE_PROVIDER_NAME;

  @override
  final doesDeserialize = false;

  @override
  List<String> get instanceFieldsAndMethods {
    final fieldsToColumns = <String>[];
    final uniqueFields = <String, String>{};
    final tableName = element.name;

    fieldsToColumns.add('''
      "${InsertTable.PRIMARY_KEY_FIELD}": {
        "name": "${InsertTable.PRIMARY_KEY_COLUMN}",
        "type": int,
        "iterable": false,
        "association": false,
      }''');

    unignoredFields.forEach((field) {
      final annotation = fields.annotationForField(field);
      final checker = checkerForField(field);
      final columnName = serializedFieldName(checker, annotation.name);
      final columnInsertionType = _finalTypeForField(field.type);

      // T0D0 support List<Future<Sibling>> for "association"
      fieldsToColumns.add('''
          "${field.name}": {
            "name": "$columnName",
            "type": $columnInsertionType,
            "iterable": ${checker.isIterable},
            "association": ${checker.isSibling || (checker.isIterable && checker.isArgTypeASibling)},
          }''');
      if (annotation.unique) {
        uniqueFields[field.name] = serializedFieldName(checker, annotation.name);
      }
    });
    final primaryKeyByUniqueColumns = _generateUniqueSqliteFunction(uniqueFields, tableName);

    return [
      "final Map<String, Map<String, dynamic>> fieldsToSqliteColumns = {${fieldsToColumns.join(',\n')}};",
      primaryKeyByUniqueColumns,
      'final String tableName = "$tableName";'
    ];
  }

  coderForField({checker, offlineFirstAnnotation, wrappedInFuture, field, fieldAnnotation}) {
    final name = serializedFieldName(checker, fieldAnnotation.name);
    if (name == InsertTable.PRIMARY_KEY_COLUMN) {
      throw InvalidGenerationSourceError(
        "Field named `${InsertTable.PRIMARY_KEY_COLUMN}` conflicts with primary key",
        todo: "Rename the field from ${InsertTable.PRIMARY_KEY_COLUMN}",
        element: field,
      );
    }

    if (fieldAnnotation?.toGenerator != null) {
      final custom = digestPlaceholders(fieldAnnotation.toGenerator, name, field.name);
      return "$custom";
    }

    // DateTime
    if (checker.isDateTime) {
      return "instance.${field.name}?.toIso8601String()";

      // bool, double, int, num, String
    } else if (checker.isDartCoreType) {
      return "instance.${field.name}";

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = OfflineFirstChecker(checker.argType);

      if (checker.isArgTypeASibling) {
        // Iterable<Future<OfflineFirstModel>>
        if (argTypeChecker.isFuture) {
          return """jsonEncode(
            (await Future.wait<int>(instance.${field.name}
              ?.map(
                (s) async => (await s)?.${InsertTable.PRIMARY_KEY_FIELD} ?? await provider?.upsert<${checker.unFuturedArgType}>((await s), repository: repository)
              )
              ?.toList()
              ?.cast<Future<int>>()
              ?? []
            )).where((s) => s != null).toList().cast<int>()
          )""";

          // Iterable<OfflineFirstModel>
        } else {
          final instanceAndField =
              wrappedInFuture ? "(await instance.${field.name})" : "instance.${field.name}";

          return """jsonEncode(
            (await Future.wait<int>($instanceAndField
              ?.map((s) async {
                return s?.${InsertTable.PRIMARY_KEY_FIELD} ?? await provider?.upsert<${checker.unFuturedArgType}>(s, repository: repository);
              })
              ?.toList()
              ?.cast<Future<int>>()
              ?? []
            )).where((s) => s != null).toList().cast<int>()
          )""";
        }
      }

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasSerializer = hasSerializer(checker.argType);
        if (_hasSerializer) {
          final serializableType = argTypeChecker.superClassTypeArgs.last.name;
          return """
            jsonEncode(instance.${field.name}?.map(
              (${checker.unFuturedArgType} c) => c?.$serializeMethod()
            )?.toList()?.cast<$serializableType>() ?? [])
          """;
        }
      }

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        return "jsonEncode(instance.${field.name}?.map((s) => ${checker.argType}.values.indexOf(s))?.toList()?.cast<int>() ?? [])";
      }

      // Iterable<bool>, Iterable<DateTime>, Iterable<double>, Iterable<int>, Iterable<num>, Iterable<String>, Iterable<Map>
      if (argTypeChecker.isDartCoreType || argTypeChecker.isMap) {
        return "jsonEncode(instance.${field.name} ?? [])";
      }

      // Iterable<Future<bool>>, Iterable<Future<DateTime>>, Iterable<Future<double>>,
      // Iterable<Future<int>>, Iterable<Future<num>>, Iterable<Future<String>>, Iterable<Future<Map>>
      if (argTypeChecker.isFuture) {
        final futureChecker = OfflineFirstChecker(argTypeChecker.argType);

        if (futureChecker.isSerializable) {
          return "jsonEncode(await Future.wait<${argTypeChecker.argType}>(instance.${field.name}) ?? [])";
        }
      }

      // OfflineFirstModel, Future<OfflineFirstModel>
    } else if (checker.isSibling) {
      final instance =
          wrappedInFuture ? "(await instance.${field.name})" : "instance.${field.name}";
      return "$instance?.${InsertTable.PRIMARY_KEY_FIELD}";

      // enum
    } else if (checker.isEnum) {
      return "${field.type}.values.indexOf(instance.${field.name})";

      // serializable non-adapter OfflineFirstModel, OfflineFirstSerdes
    } else if (checker.hasSerdes) {
      final _hasSerializer = hasSerializer(field.type);
      if (_hasSerializer) {
        return "instance.${field.name}?.$serializeMethod()";
      }

      // Map
    } else if (checker.isMap) {
      return "jsonEncode(instance.${field.name} ?? {})";
    }

    return null;
  }

  /// Generates the method `primaryKeyByUniqueColumns` for the adapter
  String _generateUniqueSqliteFunction(Map<String, String> uniqueFields, String tableName) {
    final functionDeclaration =
        'Future<int> primaryKeyByUniqueColumns(${element.name} instance, DatabaseExecutor executor) async';
    final whereStatement = List<String>();
    final valuesStatement = List<String>();
    final selectStatement = List<String>();
    uniqueFields.entries.forEach((entry) {
      whereStatement.add("${entry.value} = ?");
      valuesStatement.add("instance.${entry.key}");
      selectStatement.add(entry.value);
    });

    if (selectStatement.isEmpty && whereStatement.isEmpty) {
      return "$functionDeclaration => null;";
    }

    return '''$functionDeclaration {
      final results = await executor.rawQuery("""
        SELECT * FROM `$tableName` WHERE ${whereStatement.join(' OR ')} LIMIT 1""",
        [${valuesStatement.join(',')}]
      );

      // SQFlite returns [{}] when no results are found
      if (results?.isEmpty == true || (results?.length == 1 && results?.first?.isEmpty == true)) return null;

      return results.first['${InsertTable.PRIMARY_KEY_COLUMN}'];
    }''';
  }

  String _finalTypeForField(DartType type) {
    final checker = OfflineFirstChecker(type);
    // Future<?>, Iterable<?>
    if (checker.isFuture || checker.isIterable) {
      return _finalTypeForField(checker.argType);
    }

    return type.name;
  }
}
