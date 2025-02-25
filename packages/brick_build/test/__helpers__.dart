import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/core.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:source_gen/source_gen.dart';

export 'package:brick_build_test/brick_build_test.dart';

class FieldAnnotation extends FieldSerializable {
  @override
  String? get defaultValue => null;

  @override
  bool get enumAsString => false;

  @override
  String? get fromGenerator => null;

  @override
  String? get toGenerator => null;

  @override
  bool get ignore => false;

  @override
  bool get ignoreFrom => false;

  @override
  bool get ignoreTo => false;

  @override
  final String name;

  FieldAnnotation(this.name);
}

class FieldAnnotationFinder extends AnnotationFinder<FieldAnnotation> {
  FieldAnnotationFinder();

  @override
  FieldAnnotation from(FieldElement element) => FieldAnnotation(element.name);
}

class TestFields extends FieldsForClass<FieldAnnotation> {
  @override
  final FieldAnnotationFinder finder;

  TestFields(ClassElement element)
      : finder = FieldAnnotationFinder(),
        super(element: element);
}

class DefaultSerdes extends SerdesGenerator<FieldAnnotation, Model> {
  DefaultSerdes(super.element, super.fields);
  @override
  final providerName = 'DefaultSerdes';

  @override
  String? coderForField(
    FieldElement field,
    SharedChecker<Model> checker, {
    required FieldAnnotation fieldAnnotation,
    required bool wrappedInFuture,
  }) =>
      null;
}

class CustomSerdes extends SerdesGenerator<FieldAnnotation, Model> {
  CustomSerdes(super.element, TestFields super.fields);

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
  String coderForField(
    FieldElement field,
    SharedChecker<Model> checker, {
    required FieldAnnotation fieldAnnotation,
    required bool wrappedInFuture,
  }) {
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
    final wrappedCheckerType =
        wrappedInFuture ? 'Future<${checker.targetType}>' : checker.targetType.toString();
    return '$fieldValue as $wrappedCheckerType';
  }
}

class TestSerializableGenerator extends ProviderSerializableGenerator<AnnotationSuperGenerator> {
  TestSerializableGenerator(super.element, super.reader) : super(configKey: 'testConfig');

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
