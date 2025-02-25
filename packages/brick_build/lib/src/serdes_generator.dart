import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:brick_build/src/utils/fields_for_class.dart';
import 'package:brick_build/src/utils/shared_checker.dart';
import 'package:brick_core/core.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:dart_style/dart_style.dart' as dart_style;
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

final _formatter =
    dart_style.DartFormatter(languageVersion: dart_style.DartFormatter.latestLanguageVersion);

/// A generator that converts raw input into Dart code or Dart code into raw input. Most
/// [Provider]s will require a `SerdesGenerator` to help the Repository normalize data.
///
/// [FieldAnnotation] describes the field-level class, such as @`Rest`
/// [_SiblingModel] describes the domain or provider model, such as `SqliteModel`
abstract class SerdesGenerator<FieldAnnotation extends FieldSerializable,
    _SiblingModel extends Model> {
  /// The annotated class
  final ClassElement element;

  /// The sorted fields of the element
  final FieldsForClass<FieldAnnotation> fields;

  /// The method as printed by the adapter. Does **not** include semicolon.
  ///
  /// **Must** begin with the unnamed argument `input` and `await` the output
  /// [serializingFunctionName].
  /// Can access `input` and `provider`.
  String get adapterMethod =>
      'await $serializingFunctionName(input, provider: provider, repository: repository)';

  /// The expected input type for the [adapterMethod]
  String get adapterMethodInputType => doesDeserialize ? deserializeInputType : className;

  /// The expected output type of the [adapterMethod]
  String get adapterMethodOutputType => doesDeserialize ? className : serializeOutputType;

  ///
  String get className => element.name;

  /// Discover factories within the class that rely on the provider.
  /// For example `factory User.fromRest`
  String get constructorName => 'from$providerName';

  /// The [Type] expected from the provider when deserializing
  String get deserializeInputType => 'Map<String, dynamic>';

  /// Whether this generator serializes or deserializes raw input
  bool get doesDeserialize => true;

  /// Mash the [element]'s fields into a list for serialization or deserialization
  @visibleForTesting
  @visibleForOverriding
  String get fieldsForGenerator =>
      fields.stableInstanceFields.fold<List<String>>(<String>[], (acc, field) {
        final fieldAnnotation = fields.annotationForField(field);
        final serialization = addField(field, fieldAnnotation);
        if (serialization != null) {
          acc.add(serialization);
        }

        return acc;
      }).join(',\n');

  /// Code to follow after a class has been instantiated.
  /// **Must** end with semicolon.
  ///
  /// For example, adding non-final fields:
  /// ```dart
  /// ..primaryKey = data['${InsertTable.PRIMARY_KEY_COLUMN}'] as int;
  /// ```
  String get generateSuffix => ';';

  /// Any instance fields that should be copied to the adapter.
  /// Should terminate in `;` if required.
  List<String> get instanceFieldsAndMethods => [];

  /// For example, `Rest` or `Sqlite`
  String get providerName;

  /// Avoid linter error on subsequent passes for the repository.
  /// For example, if repository has already been casted to `!` it should not be recast
  // ignore: omit_obvious_property_types
  bool repositoryHasBeenForceCast = false;

  /// For example, `OfflineFirst`
  String get repositoryName => 'Model';

  /// Expected arguments for the serializing/deserializing function.
  /// Does **not** include parentheses.
  ///
  /// If `@override`n, implementation must include `{provider}` and `{repository}`
  /// as a named argument.
  String get serializingFunctionArguments {
    final input = doesDeserialize ? '$deserializeInputType data' : '$className instance';
    return '$input, {required ${providerName}Provider provider, ${repositoryName}Repository? repository}';
  }

  /// The generated deserialize function name
  String get serializingFunctionName {
    final action = doesDeserialize ? 'From' : 'To';
    return '_\$$className$action$providerName';
  }

  /// Discover serializers within the class that rely on the provider.
  /// For example `toRest() =>`
  String get serializeMethod => 'to$providerName';

  /// The [Type] expected by the provider when serializing
  String get serializeOutputType => 'Map<String, dynamic>';

  /// All fields that are serializable by this generator and are not declared
  /// to be ignored by an annotation.
  Iterable<FieldElement> get unignoredFields => fields.stableInstanceFields.where((field) {
        final annotation = fields.annotationForField(field);
        final checker = checkerForType(field.type);

        return (!annotation.ignore && checker.isSerializable) ||
            checker.isSerializableViaJson(doesDeserialize);
      });

  /// A generator that converts raw input into Dart code or Dart code into raw input. Most
  /// [Provider]s will require a `SerdesGenerator` to help the Repository normalize data.
  ///
  /// [FieldAnnotation] describes the field-level class, such as @`Rest`
  /// [_SiblingModel] describes the domain or provider model, such as `SqliteModel`
  SerdesGenerator(this.element, this.fields);

  /// Given each field, determine whether it can be added to the serdes function
  /// and, more importantly, determine how it should be added. If the field should not
  /// be added, return `null`.
  ///
  /// Private fields, methods, static members, and computed setters are automatically ignored.
  /// See [FieldsForClass#stableInstanceFields].
  @visibleForOverriding
  @visibleForTesting
  String? addField(FieldElement field, FieldAnnotation fieldAnnotation) {
    var wrappedInFuture = false;

    final futureChecker = SharedChecker(field.type);
    var checker = checkerForField(field);
    if (futureChecker.isFuture) {
      wrappedInFuture = true;
      checker = checkerForType(futureChecker.argType);
    }

    final shouldIgnore = ignoreCoderForField(field, fieldAnnotation, checker);
    if (shouldIgnore) return null;

    if (wrappedInFuture && checker.isIterable && checker.isArgTypeAFuture) {
      throw InvalidGenerationSourceError(
        'Future iterable future types are not supported by Brick. Please revise to `Future<Iterable<Type>>` or `Iterable<Future<Type>>`.',
        todo: 'Revise to `Future<Iterable<Type>>` or `Iterable<Future<Type>>`',
        element: field,
      );
    }

    final coder = coderForField(
      field,
      checker,
      fieldAnnotation: fieldAnnotation,
      wrappedInFuture: wrappedInFuture,
    );
    final contents = expandGenerators(fieldAnnotation, field: field, checker: checker) ?? coder;
    if (contents == null) return null;

    final name = providerNameForField(fieldAnnotation.name, checker: checker);
    if (doesDeserialize) {
      final deserializerNullability = deserializerNullableClause(
        field: field,
        fieldAnnotation: fieldAnnotation,
        name: name,
      );
      return '${field.name}: $deserializerNullability $contents';
    }

    return "'$name': $contents";
  }

  /// Generates a `repository.getAssociation` invocation
  String getAssociationMethod(
    DartType argType, {
    bool forceNullable = false,
    required String query,
  }) {
    final isNullable = argType.nullabilitySuffix != NullabilitySuffix.none;
    var repositoryOperator = isNullable ? '?' : '!';
    if (repositoryHasBeenForceCast) repositoryOperator = '';

    final thenStatement =
        forceNullable || isNullable ? 'r?.isNotEmpty ?? false ? r!.first : null' : 'r!.first';

    return '''repository
      $repositoryOperator.getAssociation<${SharedChecker.withoutNullability(argType)}>($query)
      .then((r) => $thenStatement)
    ''';
  }

  /// Return a `SharedChecker` for a type.
  /// If including a custom checker in your domain, overwrite this field
  SharedChecker checkerForType(DartType type) => SharedChecker(type);

  /// Return a `SharedChecker` for a type via the corresponding parameter in the constructor.
  ///
  /// This is necessary to support behavior where type definitions (particularly nullability)
  /// in a class member definition might not match that of the constructor. In this instance,
  /// we want to infere type from the constructor, not the field. This requires the class member
  /// name to match the parameter name in the constructor. We only want to apply this logic to
  /// deserialization, so serialization will always respect the type of the member field.
  ///
  /// Ex:
  /// ```dart
  ///   class MyClass {
  ///     final String field;
  ///
  ///     MyClass({String? field}): field = field ?? 'default';
  ///   }
  /// ```
  SharedChecker checkerForField(FieldElement field) {
    if (!doesDeserialize) return checkerForType(field.type);
    final defaultConstructor = _firstWhereOrNull<ConstructorElement>(
      element.constructors,
      (e) => !e.isFactory && e.name.isEmpty,
    );
    final defaultConstructorParameter = defaultConstructor?.parameters != null
        ? _firstWhereOrNull<ParameterElement>(
            defaultConstructor!.parameters,
            (e) => e.name == field.name,
          )
        : null;
    return checkerForType(defaultConstructorParameter?.type ?? field.type);
  }

  /// Produces serializing or deserializing method given a field and checker.
  ///
  /// The assignment (`data['my_field']: ` in serializers or `myField: ` in deserializers)
  /// is automatically injected by the superclass and should not be included in the
  /// output of the coder.
  ///
  /// To simplify checking, `Future`s are unwrapped before they get to this method.
  /// If the type was originally a future, `wrappedInFuture` is `true`.
  /// For example, `Future<List<int>>` will be an iterable according to the checker and
  /// `wrappedInFuture` will be `true`.
  String? coderForField(
    FieldElement field,
    SharedChecker checker, {
    required FieldAnnotation fieldAnnotation,
    required bool wrappedInFuture,
  });

  /// Replace default placeholders
  @mustCallSuper
  String? digestPlaceholders(String? input, String annotatedName, String fieldName) {
    if (input == null) return null;

    final newInput = input
        .replaceAll(FieldSerializable.ANNOTATED_NAME_VARIABLE, annotatedName)
        .replaceAll(FieldSerializable.DATA_PROPERTY_VARIABLE, "data['$annotatedName']")
        .replaceAll(FieldSerializable.INSTANCE_PROPERTY_VARIABLE, 'instance.$fieldName');
    return SerdesGenerator.digestCustomGeneratorPlaceholders(newInput);
  }

  /// Injected between the field member in the constructor and the contents
  String deserializerNullableClause({
    required FieldElement field,
    required FieldAnnotation fieldAnnotation,
    required String name,
  }) =>
      field.type.nullabilitySuffix != NullabilitySuffix.none
          ? "data['$name'] == null ? null :"
          : '';

  /// Convert placeholders in `fromGenerator` and `toGenerator` to functions.
  String? expandGenerators(
    FieldAnnotation annotation, {
    required FieldElement field,
    required SharedChecker checker,
  }) {
    final name = providerNameForField(annotation.name, checker: checker);

    if (doesDeserialize && annotation.fromGenerator != null) {
      return digestPlaceholders(annotation.fromGenerator, name, field.name);
    }

    if (!doesDeserialize && annotation.toGenerator != null) {
      return digestPlaceholders(annotation.toGenerator, name, field.name);
    }

    return null;
  }

  /// Wraps [fieldsForGenerator] in a method to produce serialization or deserialization
  String generate() {
    final expectedOutput = doesDeserialize ? 'Future<$className>' : 'Future<$serializeOutputType>';
    final returnWrapper =
        doesDeserialize ? '$className($fieldsForGenerator)' : '{$fieldsForGenerator}';
    final output = '''
      $expectedOutput $serializingFunctionName($serializingFunctionArguments) async {
        return $returnWrapper$generateSuffix
      }
    ''';

    return _formatter.format(output);
  }

  /// If this class possesses a factory such as `fromRest`
  @protected
  bool hasConstructor(DartType type) {
    final classElement = type.element! as ClassElement;
    return classElement.getNamedConstructor(constructorName) != null;
  }

  /// If this class possesses a serializing method such as `toSqlite`
  @protected
  bool hasSerializer(DartType type) {
    final classElement = type.element! as ClassElement;
    return classElement.getMethod(serializeMethod) != null;
  }

  /// Determine whether this field should be included in generated output.
  @protected
  bool ignoreCoderForField(
    FieldElement field,
    FieldAnnotation annotation,
    SharedChecker<Model> checker,
  ) {
    final isComputedGetter = FieldsForClass.isComputedGetter(field);

    if (isComputedGetter && doesDeserialize) return true;
    if (annotation.ignore) return true;

    final hasGenerator =
        doesDeserialize ? annotation.fromGenerator != null : annotation.toGenerator != null;
    if (!checker.isSerializable && hasGenerator) return false;

    return !(checker.isSerializable || checker.isSerializableViaJson(doesDeserialize));
  }

  /// The field's name when being serialized to a provider. Optionally, a checker can reveal
  /// the field's purpose.
  @protected
  String providerNameForField(
    String? annotatedName, {
    required SharedChecker checker,
  }) =>
      annotatedName ?? '';

  /// The field's value when used by the generator.
  /// For example, `data['my_field']` when used by a deserializing generator
  /// or `instance.myField` when used by a serializing generator
  @protected
  String serdesValueForField(
    FieldElement field,
    String annotatedName, {
    required SharedChecker checker,
  }) {
    if (doesDeserialize) {
      final name = providerNameForField(annotatedName, checker: checker);
      return "data['$name']";
    }

    return 'instance.${field.name}';
  }

  /// If the annotation includes a [FieldSerializable.defaultValue], use it when the received value is null
  static String defaultValueSuffix(FieldSerializable fieldAnnotation) =>
      fieldAnnotation.defaultValue != null ? ' ?? ${fieldAnnotation.defaultValue}' : '';

  /// If a custom generator is provided, replace variables with desired values
  /// Useful for hacking around `const` functions when duplicating logic
  static String digestCustomGeneratorPlaceholders(String input) {
    return input.replaceAllMapped(RegExp(r'%((?:[\w\d]+)+)%'), (placeholderMatch) {
      // Swap placeholders with values

      final placeholderName = placeholderMatch.group(1);
      final valueRegex = RegExp('@$placeholderName@([^@]+)@/$placeholderName@');
      if (placeholderName == null || !input.contains(valueRegex)) {
        throw InvalidGenerationSourceError('`$input` does not declare variable @$placeholderName@');
      }

      final valueMatch = valueRegex.firstMatch(input);
      if (valueMatch?.group(1) == null) {
        throw InvalidGenerationSourceError(
          '@$placeholderName@ requires a trailing value: @NAME@value@/NAME@',
        );
      }

      return valueMatch!.group(1)!;
    }).replaceAll(RegExp(r'@([\w\d]+)@.*@\/\1@'), ''); // Remove variable values
  }

  /// Cast mapped values to their desired output value
  static String iterableCast(
    DartType argType, {
    bool isSet = false,
    bool isList = false,
    bool isFuture = false,
    bool forceCast = false,
  }) {
    final nullableSuffix = argType.nullabilitySuffix != NullabilitySuffix.none ? '?' : '';
    var castStatement = nullableSuffix;
    if (isSet || isList) {
      final method = isSet ? 'Set' : 'List';
      castStatement += '.to$method()';
    }

    if (forceCast) {
      final castType = isFuture ? 'Future<$argType>' : argType;
      castStatement += '.cast<$castType>()';
    }

    return castStatement;
  }
}

// from dart:collections, instead of importing a whole package
T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
