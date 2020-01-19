import 'package:brick_build/src/utils/shared_checker.dart';
import 'package:brick_offline_first_abstract/offline_first_serdes.dart';
import 'package:source_gen/source_gen.dart' show TypeChecker;
import 'package:analyzer/dart/element/type.dart';

import 'package:brick_offline_first_abstract/offline_first_model.dart';

const _serializableClassChecker = TypeChecker.fromRuntime(OfflineFirstModel);
const _serdesClassChecker = TypeChecker.fromRuntime(OfflineFirstSerdes);

/// Utility to check for core Dart Types and and similarly-annotated
/// classes (i.e. other `OfflineFirstModel`s)
class OfflineFirstChecker extends SharedChecker {
  const OfflineFirstChecker(DartType type) : super(type);

  /// Not all [Type]s are parseable. For consistency, one catchall before smaller checks
  @override
  bool get isSerializable {
    if (targetType == null) {
      return false;
    }

    if (isIterable) {
      final argTypeChecker = OfflineFirstChecker(argType);

      return argTypeChecker.isSibling ||
          argTypeChecker.hasSerdes ||
          argTypeChecker.isDartCoreType ||
          argTypeChecker.isEnum ||
          (argTypeChecker.isFuture && argTypeChecker.canSerializeArgType);
    }

    return isDartCoreType ||
        isEnum ||
        isMap ||
        hasSerdes ||
        isSibling ||
        (isFuture && canSerializeArgType);
  }

  /// If this is a class similarly annotated by the current generator.
  ///
  /// Useful for verifying whether or not to generate Serialize/Deserializers methods.
  bool get isSibling => _serializableClassChecker.isSuperTypeOf(targetType);

  /// This class has serialize methods and deserialize factories.
  /// Useful for non-primitive types that are not associations but should still be
  /// serialized and deserialized as a field.
  bool get hasSerdes => _serdesClassChecker.isSuperTypeOf(targetType);

  /// If the sub type has super type [OfflineFirstModel]
  /// Returns `OfflineFirstModel` in `Future<OfflineFirstModel>`,
  /// `List<Future<OfflineFirstModel>>`, and `List<OfflineFirstModel>`.
  bool get isArgTypeASibling {
    if (isArgTypeAFuture) {
      final futuredType = SharedChecker.typeOfFuture(argType);
      return _serializableClassChecker.isSuperTypeOf(futuredType);
    }

    return _serializableClassChecker.isSuperTypeOf(argType);
  }

  bool get canSerializeArgType {
    final checker = OfflineFirstChecker(argType);
    return checker.isSerializable;
  }
}
