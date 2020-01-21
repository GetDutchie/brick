import 'package:analyzer/dart/element/element.dart';
import 'package:brick_core/core.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:brick_build/src/serdes_generator.dart';
import '__helpers__.dart';

final generateReader = generateLibraryForFolder('serdes_generator');

class DefaultSerdes extends SerdesGenerator<FieldAnnotation, Model> {
  DefaultSerdes(ClassElement element, TestFields fields) : super(element, fields);

  final providerName = 'DefaultSerdes';
  String coderForField(field, checker, {fieldAnnotation, wrappedInFuture}) => null;
}

class CustomSerdes extends SerdesGenerator<FieldAnnotation, Model> {
  CustomSerdes(ClassElement element, TestFields fields) : super(element, fields);

  final doesDeserialize = false;
  final deserializeInputType = 'Foo';
  final serializeOutputType = 'Bar';
  final instanceFieldsAndMethods = ["final String forwardedField = 'value';"];
  final serializingFunctionName = 'unspecificPublicMethod';
  final serializingFunctionArguments = 'Map, {provider, SomeRepository repository}';
  final generateSuffix = '..nullableField = true;';
  final className = '_CustomSerdesName';
  final adapterMethodInputType = 'String';
  final adapterMethodOutputType = 'CustomSerdes';

  final providerName = 'CustomSerdes';
  final repositoryName = 'Some';
  String coderForField(field, checker, {fieldAnnotation, wrappedInFuture}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
    return "$fieldValue as ${field.type}";
  }
}

void main() {
  group('SerdesGenerator', () {
    SerdesGenerator defaults;
    SerdesGenerator custom;

    setUpAll(() async {
      final annotation = await annotationForFile('serdes_generator', 'simple');
      defaults = DefaultSerdes(annotation.element, TestFields(annotation.element));
      custom = CustomSerdes(annotation.element, TestFields(annotation.element));
    });

    test('adapterMethod', () {
      expect(defaults.className, 'Simple');
      expect(custom.className, '_CustomSerdesName');
    });

    test('adapterMethodInputType', () {
      expect(defaults.adapterMethodInputType, 'Map<String, dynamic>');
      expect(custom.adapterMethodInputType, 'String');
    });

    test('adapterMethodOutputType', () {
      expect(defaults.adapterMethodOutputType, 'Simple');
      expect(custom.adapterMethodOutputType, 'CustomSerdes');
    });

    test('className', () {
      expect(defaults.className, 'Simple');
      expect(custom.className, '_CustomSerdesName');
    });

    test('doesDeserialize', () {
      expect(defaults.doesDeserialize, isTrue);
      expect(custom.doesDeserialize, isFalse);
    });

    test('deserializeInputType', () {
      expect(defaults.deserializeInputType, 'Map<String, dynamic>');
      expect(custom.deserializeInputType, 'Foo');
    });

    test('fieldsForGenerator', () {
      expect(defaults.fieldsForGenerator, isEmpty);
      expect(custom.fieldsForGenerator, "'some_field': instance.someField as int");
    });

    test('generateSuffix', () {
      expect(defaults.generateSuffix, ';');
      expect(custom.generateSuffix, '..nullableField = true;');
    });

    test('instanceFieldsAndMethods', () {
      expect(defaults.instanceFieldsAndMethods, isEmpty);
      expect(
        custom.instanceFieldsAndMethods,
        containsAll(["final String forwardedField = 'value';"]),
      );
    });

    test('serializeOutputType', () {
      expect(defaults.serializeOutputType, 'Map<String, dynamic>');
      expect(custom.serializeOutputType, 'Bar');
    });

    test('serializingFunctionName', () {
      expect(defaults.serializingFunctionName, r'_$SimpleFromDefaultSerdes');
      expect(custom.serializingFunctionName, 'unspecificPublicMethod');
    });

    test('serializingFunctionArguments', () {
      expect(
        defaults.serializingFunctionArguments,
        'Map<String, dynamic> data, {DefaultSerdesProvider provider, ModelRepository repository}',
      );
      expect(custom.serializingFunctionArguments, 'Map, {provider, SomeRepository repository}');
    });

    test('#addField', () {
      expect(defaults.addField, isA<Function>());
      expect(custom.addField, isA<Function>());
    });

    test('#generate', () {
      final defaultOutput = r'''
Future<Simple> _$SimpleFromDefaultSerdes(Map<String, dynamic> data,
    {DefaultSerdesProvider provider, ModelRepository repository}) async {
  return Simple();
}
''';
      final customOutput = r'''
Future<Bar> unspecificPublicMethod(Map,
    {provider, SomeRepository repository}) async {
  return {'some_field': instance.someField as int}..nullableField = true;
}
''';
      expect(defaults.generate(), defaultOutput);
      expect(custom.generate(), customOutput);
    });

    group('.digestCustomGeneratorPlaceholders', () {
      test('without a variable declaration', () {
        expect(
          () => SerdesGenerator.digestCustomGeneratorPlaceholders(
              '%UNDECLARED_VARIABLE%otherserialization'),
          throwsA(TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test('without a value', () {
        expect(
          () => SerdesGenerator.digestCustomGeneratorPlaceholders(
              '%UNDEFINED_VALUE%otherserialization@UNDEFINED_VALUE@'),
          throwsA(TypeMatcher<InvalidGenerationSourceError>()),
        );

        // Malformed declaration
        expect(
          () => SerdesGenerator.digestCustomGeneratorPlaceholders(
              '%UNDEFINED_VALUE%otherserialization@UNDEFINED_VALUE'),
          throwsA(TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test('single placeholder', () {
        final output = SerdesGenerator.digestCustomGeneratorPlaceholders(
            "data.values((v) => v.split('%DELIMITER%'))@DELIMITER@,@/DELIMITER@");
        expect(output, "data.values((v) => v.split(','))");
      });

      test('multi placeholder', () {
        final output = SerdesGenerator.digestCustomGeneratorPlaceholders(
            "%INPUT%.values((v) => v.split('%DELIMITER%'))@DELIMITER@,@/DELIMITER@@INPUT@data@/INPUT@");
        expect(output, "data.values((v) => v.split(','))");
      });
    });
  });
}
