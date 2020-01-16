import 'package:analyzer/dart/element/element.dart' show ClassElement;
import 'package:brick_build/src/offline_first/offline_first_serdes_generator.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_build/src/sqlite_serdes/sqlite_fields.dart';
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;
import 'package:brick_sqlite_abstract/db.dart' show InsertTable;
import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_build/src/offline_first/offline_first_checker.dart';

/// Generate a function to produce a [ClassElement] from SQLite data
class SqliteDeserialize extends OfflineFirstSerdesGenerator<Sqlite> {
  SqliteDeserialize(
    ClassElement element,
    SqliteFields fields, {
    String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final providerName = OfflineFirstSerdesGenerator.SQLITE_PROVIDER_NAME;

  @override
  final doesDeserialize = true;

  @override
  final generateSuffix =
      "..${InsertTable.PRIMARY_KEY_FIELD} = data['${InsertTable.PRIMARY_KEY_COLUMN}'] as int;";

  @override
  String coderForField(field, checker, {offlineFirstAnnotation, wrappedInFuture, fieldAnnotation}) {
    final name = providerNameForField(fieldAnnotation.name, checker);
    final defaultValue = SerdesGenerator.defaultValueSuffix(fieldAnnotation);
    if (field.name == InsertTable.PRIMARY_KEY_FIELD) {
      throw InvalidGenerationSourceError(
        'Field `${InsertTable.PRIMARY_KEY_FIELD}` conflicts with reserved `SqliteModel` getter.',
        todo: 'Rename the field from `${InsertTable.PRIMARY_KEY_FIELD}`',
        element: field,
      );
    }

    // DateTime
    if (checker.isDateTime) {
      return "data['$name'] == null ? null : DateTime.tryParse(data['$name']$defaultValue as String)";

      // bool
    } else if (checker.isBool) {
      return "data['$name'] == 1";

      // double, int, String
    } else if (checker.isDartCoreType) {
      return "data['$name'] as ${field.type}$defaultValue";

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = OfflineFirstChecker(checker.argType);
      final argType = checker.unFuturedArgType;
      final castIterable = SerdesGenerator.iterableCast(argType,
          isSet: checker.isSet,
          isList: checker.isList,
          isFuture: checker.isArgTypeASibling || checker.isArgTypeAFuture);

      if (checker.isArgTypeASibling) {
        final awaited = wrappedInFuture ? 'async => await' : '=>';
        final query = '''
          Query.where('${InsertTable.PRIMARY_KEY_FIELD}', ${InsertTable.PRIMARY_KEY_FIELD}, limit1: true),
        ''';
        final method = '''
          jsonDecode(data['$name'] ?? []).map((${InsertTable.PRIMARY_KEY_FIELD}) $awaited repository?.getAssociation<$argType>(
              $query
            )?.then((r) => (r?.isEmpty ?? true) ? null : r.first)
          )$castIterable
        ''';

        // Future<Iterable<OfflineFirstModel>>
        if (wrappedInFuture) {
          return 'Future.wait<$argType>($method)';
        }

        // Iterable<Future<OfflineFirstModel>>
        if (checker.isArgTypeAFuture) {
          return method;

          // Iterable<OfflineFirstModel>
        } else {
          if (checker.isSet) {
            return '(await Future.wait<$argType>($method)).toSet().cast<$argType>()';
          }

          return 'await Future.wait<$argType>($method)';
        }
      }

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasConstructor = hasConstructor(checker.argType);
        if (_hasConstructor) {
          final serializableType = argTypeChecker.superClassTypeArgs.last.getDisplayString();
          return '''
            jsonDecode(data['$name']).map(
              (c) => $argType.$constructorName(c as $serializableType)
            )$castIterable
          ''';
        }
      }

      // Iterable<DateTime>
      if (argTypeChecker.isDateTime) {
        return "jsonDecode(data['$name']).map((d) => DateTime.tryParse(d ?? ''))$castIterable";
      }

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        return "jsonDecode(data['$name']).map((d) => d as int > -1 ? $argType.values[d as int] : null)$castIterable";
      }

      // Iterable<bool>
      if (argTypeChecker.isBool) {
        return "jsonDecode(data['$name']).map((d) => d == 1)$castIterable";
      }

      // Iterable<double>, Iterable<int>, Iterable<num>, Iterable<Map>, Iterable<String>
      return "jsonDecode(data['$name'])$castIterable";

      // OfflineFirstModel, Future<OfflineFirstModel>
    } else if (checker.isSibling) {
      final query = '''
        Query.where('${InsertTable.PRIMARY_KEY_FIELD}', data['$name'] as int, limit1: true),
      ''';

      if (wrappedInFuture) {
        return '''(data['$name'] > -1
            ? repository?.getAssociation<${checker.unFuturedType}>($query)?.then((r) => (r?.isEmpty ?? true) ? null : r.first)
            : null)''';
      }

      return '''(data['$name'] > -1
            ? (await repository?.getAssociation<${checker.unFuturedType}>($query))?.first
            : null)''';

      // enum
    } else if (checker.isEnum) {
      return "(data['$name'] > -1 ? ${field.type}.values[data['$name'] as int] : null)$defaultValue";

      // serializable non-adapter OfflineFirstModel, OfflineFirstSerdes
    } else if (checker.hasSerdes) {
      final _hasConstructor = hasConstructor(field.type);
      if (_hasConstructor) {
        final serializableType = checker.superClassTypeArgs.last.getDisplayString();
        return "${field.type}.$constructorName(data['$name'] as $serializableType)";
      }

      // Map
    } else if (checker.isMap) {
      return "jsonDecode(data['$name'])";
    }

    return null;
  }
}
