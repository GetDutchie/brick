import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_checker.dart';
import 'package:brick_sqlite_generators/generators.dart';
import 'package:brick_sqlite_generators/sqlite_model_serdes_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_sqlite_generators/src/sqlite_serdes_generator.dart';

class _OfflineFirstSqliteSerialize extends SqliteSerialize<OfflineFirstWithRestModel> {
  _OfflineFirstSqliteSerialize(ClassElement element, SqliteFields fields,
      {required String repositoryName})
      : super(element, fields, repositoryName: repositoryName);

  @override
  OfflineFirstChecker checkerForType(type) => OfflineFirstChecker(type);

  @override
  String? coderForField(field, checker, {required wrappedInFuture, required fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);

    if (checker.isIterable) {
      final argTypeChecker = checkerForType(checker.argType);

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasSerializer = hasSerializer(checker.argType);
        if (_hasSerializer) {
          return '''
            jsonEncode($fieldValue?.map(
              (${checker.unFuturedArgType} c) => c.$serializeMethod()
            ).toList() ?? [])
          ''';
        }
      }
    }

    // OfflineFirstSerdes
    if ((checker as OfflineFirstChecker).hasSerdes) {
      final _hasSerializer = hasSerializer(field.type);
      if (_hasSerializer) {
        return '$fieldValue?.$serializeMethod()';
      }
    }

    return super.coderForField(field, checker,
        wrappedInFuture: wrappedInFuture, fieldAnnotation: fieldAnnotation);
  }
}

class _OfflineFirstSqliteDeserialize extends SqliteDeserialize {
  _OfflineFirstSqliteDeserialize(ClassElement element, SqliteFields fields,
      {required String repositoryName})
      : super(element, fields, repositoryName: repositoryName);

  @override
  OfflineFirstChecker checkerForType(type) => OfflineFirstChecker(type);

  @override
  String? coderForField(field, checker, {required wrappedInFuture, required fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);

    // Iterable
    if (checker.isIterable) {
      final argType = checker.unFuturedArgType;
      final argTypeChecker = OfflineFirstChecker(checker.argType);
      final castIterable = SerdesGenerator.iterableCast(argType,
          isSet: checker.isSet,
          isList: checker.isList,
          isFuture: wrappedInFuture || checker.isFuture);

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasConstructor = hasConstructor(checker.argType);
        if (_hasConstructor) {
          final serializableType =
              argTypeChecker.superClassTypeArgs.last.getDisplayString(withNullability: true);
          return '''
            jsonDecode($fieldValue).map(
              (c) => $argType.$constructorName(c as $serializableType)
            )$castIterable
          ''';
        }
      }
    }

    // OfflineFirstSerdes
    if ((checker as OfflineFirstChecker).hasSerdes) {
      final _hasConstructor = hasConstructor(field.type);
      if (_hasConstructor) {
        final serializableType =
            checker.superClassTypeArgs.last.getDisplayString(withNullability: true);
        return '${field.type}.$constructorName($fieldValue as $serializableType)';
      }
    }

    return super.coderForField(field, checker,
        wrappedInFuture: wrappedInFuture, fieldAnnotation: fieldAnnotation);
  }
}

class OfflineFirstSqliteModelSerdesGenerator extends SqliteModelSerdesGenerator {
  OfflineFirstSqliteModelSerdesGenerator(Element element, ConstantReader reader,
      {required String repositoryName})
      : super(element, reader, repositoryName: repositoryName);

  @override
  List<SqliteSerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = SqliteFields(classElement, config);
    return [
      _OfflineFirstSqliteDeserialize(classElement, fields, repositoryName: repositoryName),
      _OfflineFirstSqliteSerialize(classElement, fields, repositoryName: repositoryName),
    ];
  }
}
