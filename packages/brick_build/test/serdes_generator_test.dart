import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/builders.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '__helpers__.dart';

final generateReader = generateLibraryForFolder('serdes_generator');

void main() {
  group('SerdesGenerator', () {
    late DefaultSerdes defaults;
    late CustomSerdes custom;
    setUp(() async {
      final annotation =
          await annotationForFile<AnnotationSuperGenerator>('serdes_generator', 'simple');
      defaults = DefaultSerdes(
        annotation.element as ClassElement,
        TestFields(annotation.element as ClassElement),
      );
      custom = CustomSerdes(
        annotation.element as ClassElement,
        TestFields(annotation.element as ClassElement),
      );
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
      expect(custom.fieldsForGenerator, "'someField': instance.someField as int");
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
        'Map<String, dynamic> data, {required DefaultSerdesProvider provider, ModelRepository? repository}',
      );
      expect(custom.serializingFunctionArguments, 'Map, {provider, SomeRepository repository}');
    });

    test('#addField', () {
      expect(defaults.addField, isA<Function>());
      expect(custom.addField, isA<Function>());
    });

    test('#generate', () {
      const defaultOutput = r'''
Future<Simple> _$SimpleFromDefaultSerdes(
  Map<String, dynamic> data, {
  required DefaultSerdesProvider provider,
  ModelRepository? repository,
}) async {
  return Simple();
}
''';
      const customOutput = '''
Future<Bar> unspecificPublicMethod(
  Map, {
  provider,
  SomeRepository repository,
}) async {
  return {'someField': instance.someField as int}..nullableField = true;
}
''';
      expect(defaults.generate(), defaultOutput);
      expect(custom.generate(), customOutput);
    });

    group('.digestCustomGeneratorPlaceholders', () {
      test('without a variable declaration', () {
        expect(
          () => SerdesGenerator.digestCustomGeneratorPlaceholders(
            '%UNDECLARED_VARIABLE%otherserialization',
          ),
          throwsA(const TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test('without a value', () {
        expect(
          () => SerdesGenerator.digestCustomGeneratorPlaceholders(
            '%UNDEFINED_VALUE%otherserialization@UNDEFINED_VALUE@',
          ),
          throwsA(const TypeMatcher<InvalidGenerationSourceError>()),
        );

        // Malformed declaration
        expect(
          () => SerdesGenerator.digestCustomGeneratorPlaceholders(
            '%UNDEFINED_VALUE%otherserialization@UNDEFINED_VALUE',
          ),
          throwsA(const TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test('single placeholder', () {
        final output = SerdesGenerator.digestCustomGeneratorPlaceholders(
          "data.values((v) => v.split('%DELIMITER%'))@DELIMITER@,@/DELIMITER@",
        );
        expect(output, "data.values((v) => v.split(','))");
      });

      test('multi placeholder', () {
        final output = SerdesGenerator.digestCustomGeneratorPlaceholders(
          "%INPUT%.values((v) => v.split('%DELIMITER%'))@DELIMITER@,@/DELIMITER@@INPUT@data@/INPUT@",
        );
        expect(output, "data.values((v) => v.split(','))");
      });
    });
  });
}
