import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'file_fields.dart';
import 'file_serdes_generator.dart';

/// Read from a file's contents to produce a model
class FileDeserialize extends FileSerdesGenerator {
  FileDeserialize(
    ClassElement element,
    FileFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  final doesDeserialize = true;

  @override
  String? coderForField(field, checker, {required wrappedInFuture, required fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
    final defaultValue = SerdesGenerator.defaultValueSuffix(fieldAnnotation);

    // DateTime
    if (checker.isDateTime) {
      return '$fieldValue == null ? null : DateTime.tryParse($fieldValue$defaultValue as String)';

      // bool, double, int, num, String
    } else if (checker.isDartCoreType) {
      final wrappedCheckerType =
          wrappedInFuture ? 'Future<${checker.targetType}>' : checker.targetType.toString();
      return '$fieldValue as $wrappedCheckerType$defaultValue';

      // Iterable
    } else if (checker.isIterable) {
      final argType = checker.unFuturedArgType;
      final argTypeChecker = checkerForType(checker.argType);
      final castIterable = SerdesGenerator.iterableCast(argType,
          isSet: checker.isSet,
          isList: checker.isList,
          isFuture: wrappedInFuture || checker.isFuture);

      // Iterable<OfflineFirstModel>, Iterable<Future<OfflineFirstModel>>
      if (checker.isArgTypeASibling) {
        final fromFileCast = SerdesGenerator.iterableCast(argType,
            isSet: checker.isSet, isList: checker.isList, isFuture: true);

        var deserializeMethod = '''
          $fieldValue?.map((d) =>
            ${argType}Adapter().fromFile(d, provider: provider, repository: repository)
          )$fromFileCast
        ''';

        if (wrappedInFuture) {
          deserializeMethod = 'Future.wait<$argType>($deserializeMethod ?? [])';
        } else if (!checker.isArgTypeAFuture && !checker.isFuture) {
          deserializeMethod = 'await Future.wait<$argType>($deserializeMethod ?? [])';
        }

        if (checker.isSet) {
          return '($deserializeMethod$defaultValue)?.toSet()';
        }

        return '$deserializeMethod$defaultValue';
      }

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        return '$fieldValue.map((e) => $argType.values.indexOf(e))$castIterable$defaultValue';
      }

      // List
      if (checker.isList) {
        final addon = fieldAnnotation.defaultValue;
        return '$fieldValue$castIterable ?? $addon';

        // Set
      } else if (checker.isSet) {
        final addon = fieldAnnotation.defaultValue;
        return '$fieldValue$castIterable ?? $addon';

        // other Iterable
      } else {
        return '$fieldValue$castIterable$defaultValue';
      }
    } else if (checker.isEnum) {
      return '$fieldValue is int ? ${field.type}.values[$fieldValue as int] : null$defaultValue';

      // Map
    } else if (checker.isMap) {
      return '$fieldValue$defaultValue';
    }

    return null;
  }
}
