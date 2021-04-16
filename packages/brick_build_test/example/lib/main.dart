import 'package:source_gen/source_gen.dart';
import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/core.dart';

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_core/field_serializable.dart';

class FieldAnnotation extends FieldSerializable {
  @override
  String? get defaultValue => null;

  @override
  String? get fromGenerator => null;

  @override
  String? get toGenerator => null;

  @override
  bool get ignore => false;

  @override
  final String name;

  @override
  bool get nullable => false;

  FieldAnnotation(this.name);
}

class FieldAnnotationFinder extends AnnotationFinder<FieldAnnotation> {
  FieldAnnotationFinder();

  @override
  FieldAnnotation from(element) => FieldAnnotation(element.name);
}

class TestFields extends FieldsForClass<FieldAnnotation> {
  @override
  final FieldAnnotationFinder finder;

  TestFields(ClassElement element)
      : finder = FieldAnnotationFinder(),
        super(element: element);
}

class CustomSerdes extends SerdesGenerator<FieldAnnotation, Model> {
  CustomSerdes(ClassElement element, TestFields fields) : super(element, fields);
  @override
  final providerName = 'CustomSerdes';

  @override
  final repositoryName = 'Some';

  @override
  String coderForField(field, checker, {required fieldAnnotation, required wrappedInFuture}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
    return '$fieldValue as ${field.type}';
  }
}

class TestSerializableGenerator extends ProviderSerializableGenerator<AnnotationSuperGenerator> {
  TestSerializableGenerator(Element element, ConstantReader reader)
      : super(element, reader, configKey: 'testConfig');

  @override
  AnnotationSuperGenerator? get config => null;

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = TestFields(classElement);
    return [
      CustomSerdes(classElement, fields),
    ];
  }
}

class TestGenerator extends AnnotationSuperGenerator<AnnotationSuperGenerator> {
  @override
  final superAdapterName = 'Test';
  final repositoryName = 'Test';

  TestGenerator();

  /// Given an [element] and an [annotation], scaffold generators
  @override
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final serializableGenerator = TestSerializableGenerator(element, annotation);
    return serializableGenerator.generators;
  }
}

final _generator = TestGenerator();
final folder = 'provider_serializable_generator';
final generateReader = generateLibraryForFolder(folder);

Future<String> generateExpectation(
  String filename, {
  required TestGenerator generator,
}) async {
  final reader = await generateReader(filename);
  final generated = await generator.generate(reader, MockBuildStep());
  return generated.trim();
}

// => final generated = await generateExpectation('file_in_test_folder')
// => expect(generated, expectedOutput);

Future<String> generateAdapterExpectation(String filename) async {
  final annotation = await annotationForFile<AnnotationSuperGenerator>(folder, filename);
  final generated = _generator.generateAdapter(
    annotation.element,
    annotation.annotation,
    null,
  );
  return generated.trim();
}
// => final generated = await generateAdapterExpectation('file_in_test_folder')
// => expect(generated, expectedOutput);
