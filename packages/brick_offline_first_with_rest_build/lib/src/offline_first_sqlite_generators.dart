import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_checker.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_serdes_generator.dart';
import 'package:brick_sqlite_build/generators.dart';
import 'package:brick_sqlite_build/sqlite_serdes.dart';
import 'package:source_gen/source_gen.dart';

class _OfflineFirstSqliteSerialize extends SqliteSerialize<OfflineFirstWithRestModel> {
  _OfflineFirstSqliteSerialize(ClassElement element, SqliteFields fields)
      : super(element, fields, repositoryName: REPOSITORY_NAME);

  @override
  OfflineFirstChecker checkerForField(field, {type}) => checkerCallback(field, type: type);

  @override
  String coderForField(field, checker, {wrappedInFuture, fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);

    if (checker.isIterable) {
      final argTypeChecker = checkerForField(field, type: checker.argType);

      // Iterable<OfflineFirstSerdes>
      if (argTypeChecker.hasSerdes) {
        final _hasSerializer = hasSerializer(checker.argType);
        if (_hasSerializer) {
          final serializableType = argTypeChecker.superClassTypeArgs.last.getDisplayString();
          return '''
            jsonEncode($fieldValue?.map(
              (${checker.unFuturedArgType} c) => c?.$serializeMethod()
            )?.toList()?.cast<$serializableType>() ?? [])
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
  _OfflineFirstSqliteDeserialize(ClassElement element, SqliteFields fields)
      : super(element, fields, repositoryName: REPOSITORY_NAME);

  @override
  OfflineFirstChecker checkerForField(field, {type}) => checkerCallback(field, type: type);

  @override
  String coderForField(field, checker, {wrappedInFuture, fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);

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
      final _hasConstructor = hasConstructor(field.type);
      if (_hasConstructor) {
        final serializableType = checker.superClassTypeArgs.last.getDisplayString();
        return "${field.type}.$constructorName($fieldValue as $serializableType)";
      }
    }

    return super.coderForField(field, checker,
        wrappedInFuture: wrappedInFuture, fieldAnnotation: fieldAnnotation);
  }
}

class OfflineFirstSqliteSerdes extends SqliteSerdes {
  OfflineFirstSqliteSerdes(Element element, ConstantReader reader)
      : super(element, reader, repositoryName: REPOSITORY_NAME);

  @override
  get generators {
    final classElement = element as ClassElement;
    final fields = SqliteFields(classElement, config);
    return [
      _OfflineFirstSqliteDeserialize(classElement, fields),
      _OfflineFirstSqliteSerialize(classElement, fields),
    ];
  }
}
