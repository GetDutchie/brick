import 'package:brick_build/src/utils/shared_checker.dart';
import 'package:source_gen/source_gen.dart' show TypeChecker;
import 'package:analyzer/dart/element/type.dart';

const _siblingClassChecker = TypeChecker.fromRuntime(SqliteChecker);

/// Utility to check for core Dart Types and and similarly-annotated
/// classes (i.e. other `SqliteModel`s)
class SqliteChecker extends SharedChecker {
  const SqliteChecker(DartType type) : super(type);

  /// Not all [Type]s are parseable. For consistency, one catchall before smaller checks
  @override
  bool get isSerializable {
    if (targetType == null) {
      return false;
    }

    if (isIterable) {
      final argTypeChecker = SqliteChecker(argType);

      return argTypeChecker.isSibling ||
          argTypeChecker.isDartCoreType ||
          argTypeChecker.isEnum ||
          (argTypeChecker.isFuture && argTypeChecker.canSerializeArgType);
    }

    return isDartCoreType || isEnum || isMap || isSibling || (isFuture && canSerializeArgType);
  }

  /// If this is a class similarly annotated by the current generator.
  ///
  /// Useful for verifying whether or not to generate Serialize/Deserializers methods.
  bool get isSibling => _siblingClassChecker.isSuperTypeOf(targetType);

  /// If the sub type has super type [SqliteModel]
  /// Returns `SqliteModel` in `Future<SqliteModel>`,
  /// `List<Future<SqliteModel>>`, and `List<SqliteModel>`.
  bool get isArgTypeASibling {
    if (isArgTypeAFuture) {
      final futuredType = SharedChecker.typeOfFuture(argType);
      return _siblingClassChecker.isSuperTypeOf(futuredType);
    }

    return _siblingClassChecker.isSuperTypeOf(argType);
  }

  bool get canSerializeArgType {
    final checker = SqliteChecker(argType);
    return checker.isSerializable;
  }
}
