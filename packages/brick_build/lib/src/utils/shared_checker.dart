import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:brick_core/core.dart';
import 'package:source_gen/source_gen.dart';

const _mapChecker = TypeChecker.fromUrl('dart:core#Map');
const _iterableChecker = TypeChecker.fromUrl('dart:core#Iterable');
const _listChecker = TypeChecker.fromUrl('dart:core#List');
const _setChecker = TypeChecker.fromUrl('dart:core#Set');
const _stringChecker = TypeChecker.fromRuntime(String);
const _numChecker = TypeChecker.fromRuntime(num);
const _dateTimeChecker = TypeChecker.fromUrl('dart:core#DateTime');

/// A utility to legibly assert a [DartType] against core types
///
/// Optionally declare a model to discover "sibling" models, or models that share
/// the same domain or provider (e.g. `SqliteModel`).
class SharedChecker<_SiblingModel extends Model> {
  final _siblingClassChecker = TypeChecker.fromRuntime(_SiblingModel);

  /// The checked type
  final DartType targetType;

  /// A utility to legibly assert a [DartType] against core types
  ///
  /// Optionally declare a model to discover "sibling" models, or models that share
  /// the same domain or provider (e.g. `SqliteModel`).
  SharedChecker(this.targetType);

  /// Retrieves type argument, i.e. `Type` in `Future<Type>` or `List<Type>`
  DartType get argType => (targetType as InterfaceType).typeArguments.first;

  ///
  Type get asPrimitive {
    assert(isDartCoreType, 'type must be a core type');
    if (isBool) return bool;
    if (isDateTime) return DateTime;
    if (isDouble) return double;
    if (isInt) return int;
    if (isNum) return num;
    return String;
  }

  ///
  bool get canSerializeArgType {
    final checker = SharedChecker<_SiblingModel>(argType);
    return checker.isSerializable;
  }

  ///
  String? enumDeserializeFactory(String providerName) {
    if (!isEnum) return null;
    final element = (targetType as InterfaceType).element as EnumElement;
    for (final constructor in element.constructors) {
      if (constructor.name == 'from$providerName') return 'from$providerName';
    }
    for (final constructor in element.constructors) {
      if (constructor.name == 'fromJson') return 'fromJson';
    }
    return null;
  }

  ///
  String? enumSerializeMethod(String providerName) {
    if (!isEnum) return null;
    final element = (targetType as InterfaceType).element as EnumElement;
    for (final method in element.methods) {
      if (method.name == 'to$providerName') return 'to$providerName';
    }
    for (final method in element.methods) {
      if (method.name == 'toJson') return 'toJson';
    }
    return null;
  }

  /// Retrieves the `fromJson` factory element.
  /// If the constructor can't be found, `null` is returned.
  ConstructorElement? get fromJsonConstructor {
    if (targetType.element is ClassElement) {
      for (final constructor in (targetType.element! as ClassElement).constructors) {
        if (constructor.name == 'fromJson') return constructor;
      }
    }

    return null;
  }

  ///
  bool get isArgTypeAFuture => argType.isDartAsyncFuture || argType.isDartAsyncFutureOr;

  /// If the sub type has super type of a related [Model]
  /// Returns true for `Future<SqliteModel>`,
  /// `List<Future<SqliteModel>>`, and `List<SqliteModel>`.
  bool get isArgTypeASibling {
    if (isArgTypeAFuture) {
      final futuredType = SharedChecker.typeOfFuture<_SiblingModel>(argType);
      return _siblingClassChecker.isAssignableFromType(futuredType!);
    }

    return _siblingClassChecker.isAssignableFromType(argType);
  }

  ///
  bool get isBool => targetType.isDartCoreBool;

  /// If this is a [bool], [DateTime], [double], [int], [num], or [String]
  bool get isDartCoreType => isBool || isDateTime || isDouble || isInt || isNum || isString;

  ///
  bool get isDateTime => _dateTimeChecker.isExactlyType(targetType);

  ///
  bool get isDouble => targetType.isDartCoreDouble;

  ///
  bool get isEnum =>
      targetType is InterfaceType && (targetType as InterfaceType).element is EnumElement;

  ///
  bool get isFuture => targetType.isDartAsyncFuture || targetType.isDartAsyncFutureOr;

  ///
  bool get isInt => targetType.isDartCoreInt;

  ///
  bool get isIterable =>
      _iterableChecker.isExactlyType(targetType) ||
      _listChecker.isExactlyType(targetType) ||
      _setChecker.isExactlyType(targetType);

  ///
  bool get isList => _listChecker.isExactlyType(targetType);

  ///
  bool get isMap => _mapChecker.isExactlyType(targetType);

  ///
  bool get isNullable => targetType.nullabilitySuffix != NullabilitySuffix.none;

  ///
  bool get isNum => _numChecker.isExactlyType(targetType);

  /// Not all [Type]s are parseable. For consistency, one catchall before smaller checks
  bool get isSerializable {
    if (isIterable) {
      final argTypeChecker = SharedChecker<_SiblingModel>(argType);

      return argTypeChecker.isSibling ||
          argTypeChecker.isDartCoreType ||
          argTypeChecker.isEnum ||
          (argTypeChecker.isFuture && argTypeChecker.canSerializeArgType);
    }

    return isDartCoreType || isEnum || isMap || isSibling || (isFuture && canSerializeArgType);
  }

  ///
  bool isSerializableViaJson(bool doesDeserialize) {
    if (isIterable) {
      final argTypeChecker = SharedChecker<_SiblingModel>(argType);
      return doesDeserialize
          ? argTypeChecker.fromJsonConstructor != null
          : argTypeChecker.toJsonMethod != null;
    }
    return doesDeserialize ? fromJsonConstructor != null : toJsonMethod != null;
  }

  ///
  bool get isSet => _setChecker.isExactlyType(targetType);

  /// If this is a class similarly annotated by the current generator.
  ///
  /// Useful for verifying whether or not to generate Serialize/Deserializers methods.
  bool get isSibling => _siblingClassChecker.isAssignableFromType(targetType);

  /// If this is a [String]
  bool get isString => _stringChecker.isExactlyType(targetType);

  /// If the type is a `Future` or `FutureOr`, returns the nullability of the type of the Future.
  bool get isUnFuturedTypeNullable => unFuturedType.nullabilitySuffix != NullabilitySuffix.none;

  /// Returns type arguments of [targetType]. For example, given `Map<Key, Value>`,
  /// `[Key, Value]` is returned. If the [targetType] does not declare type arguments,
  /// return is `null`.
  List<DartType>? get typeArguments {
    final type = targetType as InterfaceType;
    if (type.typeArguments.isNotEmpty && type.typeArguments.length > 1) {
      return type.typeArguments;
    }

    return null;
  }

  /// The arguments passed to a super class definition.
  /// For example, a field `final Currency amount` with a type definition
  /// `class Currency extends OfflineFirstSerdes<T, X, Y> {}` would return `[T, X, Y]`.
  List<DartType> get superClassTypeArgs {
    final classElement = targetType.element as ClassElement?;
    if (classElement?.supertype?.typeArguments == null ||
        classElement!.supertype!.typeArguments.isEmpty) {
      throw InvalidGenerationSourceError(
        'Type argument for ${targetType.getDisplayString()} is undefined.',
        todo:
            'Define the type on class ${targetType.element}, e.g. `extends ${withoutNullability(classElement!.supertype!)}<int>`',
        element: targetType.element,
      );
    }

    return classElement.supertype!.typeArguments;
  }

  /// Retrieves the `toJson` method element.
  /// If the method can't be found, `null` is returned.
  MethodElement? get toJsonMethod {
    if (targetType.element is ClassElement) {
      for (final method in (targetType.element! as ClassElement).methods) {
        if (method.name == 'toJson') return method;
      }
    }

    return null;
  }

  /// [argType] without `Future` if it is a `Future`.
  DartType get unFuturedArgType {
    if (isArgTypeAFuture) {
      return typeOfFuture(argType)!;
    }

    return argType;
  }

  /// [targetType] without `Future` if it is a `Future`
  DartType get unFuturedType {
    if (isFuture) {
      return typeOfFuture(targetType)!;
    }

    return targetType;
  }

  /// Returns the final version of a type without decoration. It will not have a null suffix.
  ///
  /// For example, `Future<String>`, `List<Future<String>>`, `String?` and `Future<String?>`
  /// will all return `String`.
  String get withoutNullResultType {
    final typeRemover = RegExp(r'\<[,\s\w]+\>');

    // Future<?>, Iterable<?>
    if (isFuture || isIterable) {
      final checker = SharedChecker<_SiblingModel>(argType);
      return checker.withoutNullResultType;
    }

    if (toJsonMethod != null) {
      return withoutNullability(toJsonMethod!.returnType).replaceAll(typeRemover, '');
    }

    // remove arg types as they can't be declared in final fields
    return withoutNullability(targetType).replaceAll(typeRemover, '');
  }

  /// Print the `DartType` without nullability
  static String withoutNullability(DartType type) => type.getDisplayString().replaceAll('?', '');

  /// Destructs a type to determine the bottom type after going through Futures and Iterables.
  ///
  /// For example, `int` in `Future<int>` or `List<String>` in `Future<List<String>>`.
  ///
  /// `Future`s of `Future` iterables (e.g. `Future<List<Future<String>>>`) are not supported,
  /// however, `Future`s in Iterables are supported (e.g. `List<Future<String>>`).
  static DartType? typeOfFuture<_SiblingModel extends Model>(DartType type) {
    final checker = SharedChecker<_SiblingModel>(type);
    // Future<?>
    if (checker.isFuture) {
      return checker.argType;
    } else {
      // Iterable<Future<?>>
      if (checker.isIterable) {
        final iterableChecker = SharedChecker<_SiblingModel>(checker.argType);

        // Future<?>
        if (iterableChecker.isFuture) {
          return iterableChecker.argType;
        }
      }
    }

    return null;
  }
}
