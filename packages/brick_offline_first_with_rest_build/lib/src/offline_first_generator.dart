import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/adapter_generator.dart';
import 'package:brick_build/src/annotation_super_generator.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_rest_generators.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_sqlite_generators.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_offline_first_abstract/annotations.dart';

/// Output serializing code for all models with the @[ConnectOfflineFirstWithRest] annotation
class OfflineFirstGenerator extends AnnotationSuperGenerator<ConnectOfflineFirstWithRest> {
  /// The prefix to the adapter name; useful if extending `OfflineFirstRepository`.
  /// Defaults to `OfflineFirst`.
  final String superAdapterName;

  /// The prefix to the repository name, specified when declaring the repository type in
  /// serializing functions; useful if extending `OfflineFirstRepository`.
  /// Defaults to `OfflineFirst`.
  final String repositoryName;

  const OfflineFirstGenerator({
    this.superAdapterName = 'OfflineFirst',
    this.repositoryName = 'OfflineFirst',
  });

  /// Given an [element] and an [annotation], scaffold generators
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final rest = OfflineFirstRestSerdes(element, annotation);
    final sqlite = OfflineFirstSqliteSerdes(element, annotation);
    final generators = <SerdesGenerator>[];
    generators.addAll(rest.generators);
    generators.addAll(sqlite.generators);
    return generators;
  }

  @override
  String generateForAnnotatedElement(element, annotation, buildStep) {
    final generators = buildGenerators(element, annotation);

    return generators.fold<List<String>>(<String>[], (acc, generator) {
      acc.add(generator.generate());
      return acc;
    }).join('\n');
  }

  @override
  String generateAdapter(Element element, ConstantReader annotation, BuildStep buildStep) {
    final generators = buildGenerators(element, annotation);

    final adapterGenerator = AdapterGenerator(
      superAdapterName: superAdapterName,
      className: element.name,
      generators: generators,
    );

    return adapterGenerator.generate();
  }
}
