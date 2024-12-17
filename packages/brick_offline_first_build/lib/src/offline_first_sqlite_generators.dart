import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/src/model.dart';
import 'package:brick_offline_first_build/src/offline_first_checker.dart';
import 'package:brick_sqlite/src/annotations/sqlite.dart';
import 'package:brick_sqlite_generators/generators.dart';
import 'package:brick_sqlite_generators/sqlite_model_serdes_generator.dart';

///
class OfflineFirstSqliteSerialize extends SqliteSerialize {
  ///
  OfflineFirstSqliteSerialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });

  @override
  OfflineFirstChecker checkerForType(DartType type) => OfflineFirstChecker(type);

  @override
  String? coderForField(
    FieldElement field,
    SharedChecker<Model> checker, {
    required bool wrappedInFuture,
    required Sqlite fieldAnnotation,
  }) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);

    if (checker.isIterable) {
      final argTypeChecker = checkerForType(checker.argType);

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final doesHaveSerializer = hasSerializer(checker.argType);
        if (doesHaveSerializer) {
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

  @override
  String uniqueValueForField(String? fieldName, {required SharedChecker<Model> checker}) {
    if ((checker as OfflineFirstChecker).hasSerdes) {
      return '$fieldName.toSqlite()';
    }

    return super.uniqueValueForField(fieldName, checker: checker);
  }
}

///
class OfflineFirstSqliteDeserialize extends SqliteDeserialize {
  ///
  OfflineFirstSqliteDeserialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });

  @override
  OfflineFirstChecker checkerForType(DartType type) => OfflineFirstChecker(type);

  @override
  String? coderForField(
    FieldElement field,
    SharedChecker<Model> checker, {
    required bool wrappedInFuture,
    required Sqlite fieldAnnotation,
  }) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name!, checker: checker);

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

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final doesHaveConstructor = hasConstructor(checker.argType);
        if (doesHaveConstructor) {
          final serializableType = argTypeChecker.superClassTypeArgs.last.getDisplayString();
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
      final doesHaveConstructor = hasConstructor(field.type);
      if (doesHaveConstructor) {
        final serializableType = checker.superClassTypeArgs.last.getDisplayString();
        return '${SharedChecker.withoutNullability(field.type)}.$constructorName($fieldValue as $serializableType)';
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

///
class OfflineFirstSqliteModelSerdesGenerator extends SqliteModelSerdesGenerator {
  ///
  OfflineFirstSqliteModelSerdesGenerator(
    super.element,
    super.reader, {
    required super.repositoryName,
  });

  @override
  List<SqliteSerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = SqliteFields(classElement, config);
    return [
      OfflineFirstSqliteDeserialize(classElement, fields, repositoryName: repositoryName),
      OfflineFirstSqliteSerialize(classElement, fields, repositoryName: repositoryName),
    ];
  }
}
