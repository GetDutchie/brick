import 'package:brick_build/generators.dart' show SharedChecker;
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:source_gen/source_gen.dart' show TypeChecker;

const _serdesClassChecker = TypeChecker.fromRuntime(OfflineFirstSerdes);

///
class OfflineFirstChecker extends SharedChecker<OfflineFirstModel> {
  ///
  OfflineFirstChecker(super.targetType);

  @override
  bool get isSerializable {
    final alreadySerializable = super.isSerializable;
    if (alreadySerializable) return true;

    if (isIterable) {
      final argTypeChecker = OfflineFirstChecker(argType);

      return argTypeChecker.hasSerdes ||
          (argTypeChecker.isFuture && argTypeChecker.canSerializeArgType);
    }

    return hasSerdes || (isFuture && canSerializeArgType);
  }

  /// This class has serialize methods and deserialize factories.
  /// Useful for non-primitive types that are not associations but should still be
  /// serialized and deserialized as a field.
  bool get hasSerdes => _serdesClassChecker.isAssignableFromType(targetType);
}
