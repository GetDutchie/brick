export 'package:brick_build/testing.dart';

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:brick_core/core.dart';
import 'package:source_gen/source_gen.dart';

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

class DefaultSerdes extends SerdesGenerator<FieldAnnotation, Model> {
  DefaultSerdes(ClassElement element, TestFields fields) : super(element, fields);
  @override
  final providerName = 'DefaultSerdes';

  @override
  String? coderForField(field, checker, {fieldAnnotation, wrappedInFuture}) => null;
}

class CustomSerdes extends SerdesGenerator<FieldAnnotation, Model> {
  CustomSerdes(ClassElement element, TestFields fields) : super(element, fields);

  @override
  final doesDeserialize = false;

  @override
  final deserializeInputType = 'Foo';

  @override
  final serializeOutputType = 'Bar';

  @override
  final instanceFieldsAndMethods = ["final String forwardedField = 'value';"];

  @override
  final serializingFunctionName = 'unspecificPublicMethod';

  @override
  final serializingFunctionArguments = 'Map, {provider, SomeRepository repository}';

  @override
  final generateSuffix = '..nullableField = true;';

  @override
  final className = '_CustomSerdesName';

  @override
  final adapterMethodInputType = 'String';

  @override
  final adapterMethodOutputType = 'CustomSerdes';

  @override
  final providerName = 'CustomSerdes';

  @override
  final repositoryName = 'Some';

  @override
  String coderForField(field, checker, {fieldAnnotation, wrappedInFuture}) {
    final fieldValue = serdesValueForField(field, fieldAnnotation?.name ?? '', checker: checker);
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

/// Output serializing code for all models with the @[AnnotationSuperGenerator] annotation.
/// [AnnotationSuperGenerator] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [AnnotationSuperGenerator] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
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
