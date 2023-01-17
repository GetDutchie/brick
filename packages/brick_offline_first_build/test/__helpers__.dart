import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest_generators/generators.dart';
import 'package:brick_rest_generators/rest_model_serdes_generator.dart';
import 'package:test/test.dart';
import 'package:brick_build_test/brick_build_test.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_rest/brick_rest.dart';

final _generator = OfflineFirstWithTestGenerator();
final folder = 'offline_first_generator';
final generateReader = generateLibraryForFolder(folder);

Future<void> generateExpectation(String filename, String output,
    {OfflineFirstWithTestGenerator? generator}) async {
  final reader = await generateReader(filename);
  final generated = await (generator ?? _generator).generate(reader, MockBuildStep());
  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(String filename, String output,
    {OfflineFirstWithTestGenerator? generator}) async {
  final annotation = await annotationForFile<ConnectOfflineFirstWithRest>(folder, filename);
  final generated = (generator ?? _generator).generateAdapter(
    annotation.element,
    annotation.annotation,
    MockBuildStep(),
  );
  expect(generated.trim(), output.trim());
}

class _OfflineFirstTestSerialize extends RestSerialize
    with OfflineFirstJsonSerialize<RestModel, Rest> {
  @override
  final OfflineFirstFields offlineFirstFields;

  @override
  final providerName = 'Test';

  _OfflineFirstTestSerialize(ClassElement element, RestFields fields,
      {required String repositoryName})
      : offlineFirstFields = OfflineFirstFields(element),
        super(element, fields, repositoryName: repositoryName);
}

class _OfflineFirstTestDeserialize extends RestDeserialize
    with OfflineFirstJsonDeserialize<RestModel, Rest> {
  @override
  final OfflineFirstFields offlineFirstFields;

  @override
  final providerName = 'Test';

  _OfflineFirstTestDeserialize(ClassElement element, RestFields fields,
      {required String repositoryName})
      : offlineFirstFields = OfflineFirstFields(element),
        super(element, fields, repositoryName: repositoryName);
}

class OfflineFirstTestModelSerdesGenerator extends RestModelSerdesGenerator {
  OfflineFirstTestModelSerdesGenerator(Element element, ConstantReader reader,
      {required String repositoryName})
      : super(element, reader, repositoryName: repositoryName);

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = RestFields(classElement, config);
    return [
      _OfflineFirstTestDeserialize(classElement, fields, repositoryName: repositoryName!),
      _OfflineFirstTestSerialize(classElement, fields, repositoryName: repositoryName!),
    ];
  }
}

class OfflineFirstWithTestGenerator extends OfflineFirstGenerator<ConnectOfflineFirstWithRest> {
  const OfflineFirstWithTestGenerator({
    String? repositoryName,
    String? superAdapterName,
  }) : super(
          repositoryName: repositoryName,
          superAdapterName: superAdapterName,
        );

  /// Given an [element] and an [annotation], scaffold generators
  @override
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final rest =
        OfflineFirstTestModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
    final sqlite =
        OfflineFirstSqliteModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
    final generators = <SerdesGenerator>[];
    generators.addAll(rest.generators);
    generators.addAll(sqlite.generators);
    return generators;
  }
}
