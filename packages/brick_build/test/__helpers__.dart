export 'package:brick_build/testing.dart';

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:brick_core/core.dart';
import 'package:source_gen/source_gen.dart';

class FieldAnnotation extends FieldSerializable {
  get defaultValue => null;
  String get fromGenerator => null;
  String get toGenerator => null;
  bool get ignore => false;
  final String name;
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

class TestSerializableGenerator extends ProviderSerializableGenerator<AnnotationSuperGenerator> {
  TestSerializableGenerator(Element element, ConstantReader reader)
      : super(element, reader, configKey: 'testConfig');

  @override
  AnnotationSuperGenerator get config => null;

  @override
  get generators {
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
  final superAdapterName = 'Test';
  final repositoryName = 'Test';

  TestGenerator();

  /// Given an [element] and an [annotation], scaffold generators
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final serializableGenerator = TestSerializableGenerator(element, annotation);
    return serializableGenerator.generators;
  }
}
