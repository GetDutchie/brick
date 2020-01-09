import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/utils/fields_for_class.dart';
import 'package:dart_style/dart_style.dart' as dart_style;
import 'package:source_gen/source_gen.dart';

final _formatter = dart_style.DartFormatter();

/// A generator that converts raw input into Dart code or Dart code into raw input. Most
/// [Provider]s will require a `SerdesGenerator` to help the Repository normalize data.
abstract class SerdesGenerator<_FieldAnnotation> {
  /// The annotated class
  final ClassElement element;

  /// The sorted fields of the element
  final FieldsForClass<_FieldAnnotation> fields;

  /// The method as printed by the adapter. Does **not** include semicolon.
  ///
  /// **Must** begin with the unnamed argument `input` and `await` the output
  /// [serializingFunctionName].
  /// Can access `input` and `provider`.
  String get adapterMethod {
    return "await $serializingFunctionName(input, provider: provider, repository: repository)";
  }

  /// The expected input type for the [adapterMethod]
  String get adapterMethodInputType => doesDeserialize ? deserializeInputType : className;

  /// The expected output type of the [adapterMethod]
  String get adapterMethodOutputType => doesDeserialize ? className : serializeOutputType;

  String get className => element.name;

  /// The [Type] expected from the provider when deserializing
  String get deserializeInputType => 'Map<String, dynamic>';

  /// Whether this generator serializes or deserializes raw input
  bool get doesDeserialize => true;

  /// Mash the [element]'s fields into a list for serialization or deserialization
  String get fieldsForGenerator {
    return fields.stableInstanceFields.fold(List<String>(), (acc, field) {
      final fieldAnnotation = fields.annotationForField(field);
      final serialization = addField(field, fieldAnnotation);
      if (serialization != null) {
        acc.add(serialization);
      }

      return acc;
    }).join(',\n');
  }

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

  /// For example, `OfflineFirst`
  String get repositoryName => "Model";

  /// Expected arguments for the serializing/deserializing function.
  /// Does **not** include parentheses.
  ///
  /// If `@override`n, implementation must include `{provider}` and `{repository}`
  /// as a named argument.
  String get serializingFunctionArguments {
    final input = doesDeserialize ? '$deserializeInputType data' : '$className instance';
    return "$input, {${providerName}Provider provider, ${repositoryName}Repository repository}";
  }

  /// The generated deserialize function name
  String get serializingFunctionName {
    final action = doesDeserialize ? 'From' : 'To';
    return "_\$${className}$action$providerName";
  }

  /// The [Type] expected by the provider when serializing
  String get serializeOutputType => 'Map<String, dynamic>';

  SerdesGenerator(ClassElement this.element, FieldsForClass<_FieldAnnotation> this.fields);

  /// Given each field, determine whether it can be added to the serdes function
  /// and, more importantly, determine how it should be added. If the field should not
  /// be added, return `null`.
  ///
  /// Private fields, methods, static members, and computed setters are automatically ignored.
  /// See [FieldsForClass#stableInstanceFields].
  String addField(FieldElement field, _FieldAnnotation fieldAnnotation);

  /// If a custom generator is provided, replace variables with desired values
  /// Useful for hacking around `const` functions when duplicating logic
  String digestCustomGeneratorPlaceholders(String input) {
    return input.replaceAllMapped(RegExp(r"%((?:[\w\d]+)+)%"), (placeholderMatch) {
      // Swap placeholders with values

      final placeholderName = placeholderMatch?.group(1);
      final valueRegex = RegExp("@$placeholderName@([^@]+)@/$placeholderName@");
      if (placeholderName == null || !input.contains(valueRegex)) {
        throw InvalidGenerationSourceError("`$input` does not declare variable @$placeholderName@");
      }

      final valueMatch = valueRegex.firstMatch(input);
      if (valueMatch?.group(1) == null) {
        throw InvalidGenerationSourceError(
            "@$placeholderName@ requires a trailing value: @NAME@value@/NAME@");
      }

      return valueMatch.group(1);
    }).replaceAll(RegExp(r"@([\w\d]+)@.*@\/\1@"), ""); // Remove variable values
  }

  /// Wraps [fieldsForGenerator] in a method to produce serialization or deserialization
  String generate() {
    final expectedOutput = doesDeserialize ? "Future<$className>" : "Future<$serializeOutputType>";
    final returnWrapper =
        doesDeserialize ? "$className($fieldsForGenerator)" : "{$fieldsForGenerator}";
    final output = """
      $expectedOutput ${serializingFunctionName}($serializingFunctionArguments) async {
        return $returnWrapper$generateSuffix
      }
    """;

    return _formatter.format(output);
  }
}
