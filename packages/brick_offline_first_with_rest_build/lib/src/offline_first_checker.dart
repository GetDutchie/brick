import 'package:brick_build/src/utils/shared_checker.dart';
import 'package:brick_offline_first_abstract/offline_first_serdes.dart';
import 'package:source_gen/source_gen.dart' show TypeChecker;
import 'package:analyzer/dart/element/type.dart';

import 'package:brick_offline_first_abstract/offline_first_model.dart';

const _serdesClassChecker = TypeChecker.fromRuntime(OfflineFirstSerdes);

class OfflineFirstChecker extends SharedChecker<OfflineFirstModel> {
  OfflineFirstChecker(DartType type) : super(type);

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
  bool get hasSerdes => _serdesClassChecker.isSuperTypeOf(targetType);
}
