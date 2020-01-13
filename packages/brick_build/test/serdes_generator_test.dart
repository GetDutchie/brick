import 'package:analyzer/dart/element/element.dart';
import 'package:brick_rest/rest.dart' show Rest;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_build/src/rest_serdes/rest_fields.dart';
import '__helpers__.dart';

final generateReader = generateLibraryForFolder('serdes_generator');

class DefaultSerdes extends SerdesGenerator<Rest> {
  DefaultSerdes(ClassElement element, RestFields fields) : super(element, fields);

  final providerName = "DefaultSerdes";
  String addField(FieldElement field, Rest fieldAnnotation) => null;
}

class CustomSerdes extends SerdesGenerator<Rest> {
  CustomSerdes(ClassElement element, RestFields fields) : super(element, fields);

  final doesDeserialize = false;
  final deserializeInputType = "Foo";
  final serializeOutputType = "Bar";
  final instanceFieldsAndMethods = ['final String forwardedField = "value";'];
  final serializingFunctionName = "unspecificPublicMethod";
  final serializingFunctionArguments = "Map, {provider, SomeRepository repository}";
  final generateSuffix = "..nullableField = true;";
  final className = "_CustomSerdesName";
  final adapterMethodInputType = "String";
  final adapterMethodOutputType = "CustomSerdes";

  final providerName = "CustomSerdes";
  final repositoryName = "Some";
  String addField(FieldElement field, Rest fieldAnnotation) {
    return "${field.name}: '${field.type.getDisplayString()}'";
  }
}

void main() {
  group("SerdesGenerator", () {
    SerdesGenerator defaults;
    SerdesGenerator custom;

    setUpAll(() async {
      final annotation = await annotationForFile('serdes_generator', 'simple');
      defaults = DefaultSerdes(annotation.element, RestFields(annotation.element));
      custom = CustomSerdes(annotation.element, RestFields(annotation.element));
    });

    test("adapterMethod", () {
      expect(defaults.className, "Simple");
      expect(custom.className, "_CustomSerdesName");
    });

    test("adapterMethodInputType", () {
      expect(defaults.adapterMethodInputType, "Map<String, dynamic>");
      expect(custom.adapterMethodInputType, "String");
    });

    test("adapterMethodOutputType", () {
      expect(defaults.adapterMethodOutputType, "Simple");
      expect(custom.adapterMethodOutputType, "CustomSerdes");
    });

    test("className", () {
      expect(defaults.className, "Simple");
      expect(custom.className, "_CustomSerdesName");
    });

    test("doesDeserialize", () {
      expect(defaults.doesDeserialize, isTrue);
      expect(custom.doesDeserialize, isFalse);
    });

    test("deserializeInputType", () {
      expect(defaults.deserializeInputType, 'Map<String, dynamic>');
      expect(custom.deserializeInputType, 'Foo');
    });

    test("fieldsForGenerator", () {
      expect(defaults.fieldsForGenerator, isEmpty);
      expect(custom.fieldsForGenerator, "someField: 'int'");
    });

    test("generateSuffix", () {
      expect(defaults.generateSuffix, ";");
      expect(custom.generateSuffix, "..nullableField = true;");
    });

    test("instanceFieldsAndMethods", () {
      expect(defaults.instanceFieldsAndMethods, isEmpty);
      expect(
        custom.instanceFieldsAndMethods,
        containsAll(['final String forwardedField = "value";']),
      );
    });

    test("serializeOutputType", () {
      expect(defaults.serializeOutputType, 'Map<String, dynamic>');
      expect(custom.serializeOutputType, 'Bar');
    });

    test("serializingFunctionName", () {
      expect(defaults.serializingFunctionName, r"_$SimpleFromDefaultSerdes");
      expect(custom.serializingFunctionName, "unspecificPublicMethod");
    });

    test("serializingFunctionArguments", () {
      expect(
        defaults.serializingFunctionArguments,
        "Map<String, dynamic> data, {DefaultSerdesProvider provider, ModelRepository repository}",
      );
      expect(custom.serializingFunctionArguments, "Map, {provider, SomeRepository repository}");
    });

    test("#addField", () {
      expect(defaults.addField, isA<Function>());
      expect(custom.addField, isA<Function>());
    });

    test("#generate", () {
      final defaultOutput = r"""
Future<Simple> _$SimpleFromDefaultSerdes(Map<String, dynamic> data,
    {DefaultSerdesProvider provider, ModelRepository repository}) async {
  return Simple();
}
""";
      final customOutput = r"""
Future<Bar> unspecificPublicMethod(Map,
    {provider, SomeRepository repository}) async {
  return {someField: 'int'}..nullableField = true;
}
""";
      expect(defaults.generate(), defaultOutput);
      expect(custom.generate(), customOutput);
    });

    group("#digestCustomGeneratorPlaceholders", () {
      test("without a variable declaration", () {
        expect(
          () =>
              defaults.digestCustomGeneratorPlaceholders("%UNDECLARED_VARIABLE%otherserialization"),
          throwsA(TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test("without a value", () {
        expect(
          () => defaults.digestCustomGeneratorPlaceholders(
              "%UNDEFINED_VALUE%otherserialization@UNDEFINED_VALUE@"),
          throwsA(TypeMatcher<InvalidGenerationSourceError>()),
        );

        // Malformed declaration
        expect(
          () => defaults.digestCustomGeneratorPlaceholders(
              "%UNDEFINED_VALUE%otherserialization@UNDEFINED_VALUE"),
          throwsA(TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test("single placeholder", () {
        final output = defaults.digestCustomGeneratorPlaceholders(
            "data.values((v) => v.split('%DELIMITER%'))@DELIMITER@,@/DELIMITER@");
        expect(output, "data.values((v) => v.split(','))");
      });

      test("multi placeholder", () {
        final output = defaults.digestCustomGeneratorPlaceholders(
            "%INPUT%.values((v) => v.split('%DELIMITER%'))@DELIMITER@,@/DELIMITER@@INPUT@data@/INPUT@");
        expect(output, "data.values((v) => v.split(','))");
      });
    });
  });
}
