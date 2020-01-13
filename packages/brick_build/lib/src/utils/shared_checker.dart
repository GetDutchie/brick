import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';

const _mapChecker = TypeChecker.fromUrl('dart:core#Map');
const _iterableChecker = TypeChecker.fromUrl('dart:core#Iterable');
const _listChecker = TypeChecker.fromUrl('dart:core#List');
const _setChecker = TypeChecker.fromUrl('dart:core#Set');
const _stringChecker = TypeChecker.fromRuntime(String);
const _numChecker = TypeChecker.fromRuntime(num);
const _dateTimeChecker = TypeChecker.fromUrl('dart:core#DateTime');

/// A utility to legibly assert a [DartType] against core types
class SharedChecker {
  /// The checked type
  final DartType targetType;

  const SharedChecker(this.targetType);

  /// Retrieves type argument, i.e. `Type` in `Future<Type>` or `List<Type>`
  DartType get argType {
    return (targetType as InterfaceType)?.typeArguments?.first;
  }

  Type get asPrimitive {
    assert(isDartCoreType);
    if (isBool) return bool;
    if (isDateTime) return DateTime;
    if (isDouble) return double;
    if (isInt) return int;
    if (isNum) return num;
    return String;
  }

  bool get isArgTypeAFuture {
    if (argType == null) {
      return false;
    }

    return argType.isDartAsyncFuture || argType.isDartAsyncFutureOr;
  }

  bool get isBool => targetType.isDartCoreBool;

  /// If this is a [bool], [DateTime], [double], [int], [num], or [String]
  bool get isDartCoreType => isBool || isDateTime || isDouble || isInt || isNum || isString;

  bool get isDateTime => _dateTimeChecker.isExactlyType(targetType);

  bool get isDouble => targetType.isDartCoreDouble;

  bool get isEnum {
    return targetType is InterfaceType && (targetType as InterfaceType).element.isEnum;
  }

  bool get isFuture => targetType.isDartAsyncFuture || targetType.isDartAsyncFutureOr;

  bool get isInt => targetType.isDartCoreInt;

  bool get isIterable =>
      _iterableChecker.isExactlyType(targetType) ||
      _listChecker.isExactlyType(targetType) ||
      _setChecker.isExactlyType(targetType);

  bool get isList => _listChecker.isExactlyType(targetType);

  bool get isMap => _mapChecker.isExactlyType(targetType);

  /// Not all [Type]s are parseable. For consistency, one catchall before smaller checks
  bool get isSerializable {
    return isDartCoreType || isEnum || isIterable || isMap || isFuture;
  }

  bool get isNum => _numChecker.isExactlyType(targetType);

  bool get isSet => _setChecker.isExactlyType(targetType);

  bool get isString => _stringChecker.isExactlyType(targetType);

  /// Returns the type arguments of `Map<Key, Value>` as `[Key, Value]`.
  /// If the Map does not declare type arguments, return is `null`.
  List<DartType> get mapArgs {
    assert(isMap, "$targetType is not a Map");

    final type = targetType as InterfaceType;
    if (type.typeArguments.isNotEmpty && type.typeArguments.length > 1) {
      return [type.typeArguments.first, type.typeArguments.last];
    }

    return null;
  }

  /// The arguments passed to a super class definition.
  /// For example, a field `final Currency amount` with a type definition
  /// `class Currency extends OfflineFirstSerdes<T, X, Y> {}` would return `[T, X, Y]`.
  List<DartType> get superClassTypeArgs {
    final classElement = targetType.element as ClassElement;
    if (classElement.supertype?.typeArguments == null ||
        classElement.supertype.typeArguments.isEmpty) {
      throw InvalidGenerationSourceError(
        "Type argument for ${targetType.getDisplayString()} is undefined.",
        todo:
            "Define the type on class ${targetType.element}, e.g. `extends ${classElement.supertype.getDisplayString()}<int>`",
        element: targetType.element,
      );
    }

    return classElement.supertype.typeArguments;
  }

  /// [argType] without `Future` if it is a `Future`.
  DartType get unFuturedArgType {
    if (isArgTypeAFuture) {
      return typeOfFuture(argType);
    }

    return argType;
  }

  /// [targetType] without `Future` if it is a `Future`
  DartType get unFuturedType {
    if (isFuture) {
      return typeOfFuture(targetType);
    }

    return targetType;
  }

  /// Destructures a type to determine the bottom type after going through Futures and Iterables.
  ///
  /// For example, `int` in `Future<int>` or `List<String>` in `Future<List<String>>`.
  ///
  /// `Future`s of `Future` iterables (e.g. `Future<List<Future<String>>>`) are not supported,
  /// however, `Future`s in Iterables are supported (e.g. `List<Future<String>>`).
  static DartType typeOfFuture(DartType type) {
    final checker = SharedChecker(type);
    // Future<?>
    if (checker.isFuture) {
      return checker.argType;
    } else {
      // Iterable<Future<?>>
      if (checker.isIterable) {
        final iterableChecker = SharedChecker(checker.argType);

        // Future<?>
        if (iterableChecker.isFuture) {
          return iterableChecker.argType;
        }
      }
    }

    return null;
  }
}
