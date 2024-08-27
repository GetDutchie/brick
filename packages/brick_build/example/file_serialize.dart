import 'package:brick_build/generators.dart';

import 'file_serdes_generator.dart';

/// Generate serialized code for each field to write to a file
class FileSerialize<_Model extends FileModel> extends FileSerdesGenerator<_Model> {
  FileSerialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });

  @override
  final doesDeserialize = false;

  @override
  String? coderForField(field, checker, {required wrappedInFuture, required fieldAnnotation}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);

    // DateTime
    if (checker.isDateTime) {
      return '$fieldValue?.toIso8601String()';

      // bool, double, int, num, String, Map, Iterable, enum
    } else if ((checker.isDartCoreType) || checker.isMap) {
      return fieldValue;

      // Iterable
    } else if (checker.isIterable) {
      final argTypeChecker = checkerForType(checker.argType);

      // Iterable<enum>
      if (argTypeChecker.isEnum) {
        return '$fieldValue?.map((e) => ${SharedChecker.withoutNullability(checker.argType)}.values.indexOf(e))';
      }

      // Iterable<OfflineFirstModel>, Iterable<Future<OfflineFirstModel>>
      if (checker.isArgTypeASibling) {
        final awaited = checker.isArgTypeAFuture ? 'async' : '';
        final awaitedValue = checker.isArgTypeAFuture ? '(await s)' : 's';
        return '''await Future.wait<Map<String, dynamic>>(
          $fieldValue?.map((s) $awaited =>
            ${checker.unFuturedArgType}Adapter().toFile($awaitedValue)
          )?.toList() ?? []
        )''';
      }

      return fieldValue;
    } else if (checker.isEnum) {
      return '$fieldValue != null ? ${field.type}.values.indexOf($fieldValue) : null';
    }

    return null;
  }
}
