import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/adapter_generator.dart';
import 'package:brick_build/src/annotation_super_generator.dart';
import 'package:brick_build/src/offline_first/rest_serdes.dart';
import 'package:brick_build/src/offline_first/sqlite_serdes.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_offline_first_abstract/annotations.dart';

/// Output serializing code for all models with the @[ConnectOfflineFirst] annotation
class OfflineFirstGenerator extends AnnotationSuperGenerator<ConnectOfflineFirst> {
  /// The prefix to the adapter name; useful if extending `OfflineFirstRepository`.
  /// Defaults to `OfflineFirst`.
  final String superAdapterName;

  /// The prefix to the repository name, specified when declaring the repository type in
  /// serializing functions; useful if extending `OfflineFirstRepository`.
  /// Defaults to `OfflineFirst`.
  final String repositoryName;

  const OfflineFirstGenerator({
    this.superAdapterName = "OfflineFirst",
    this.repositoryName = "OfflineFirst",
  });

  /// Given an [element] and an [annotation], scaffold generators
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final rest = RestSerdes(element, annotation, repositoryName: repositoryName);
    final sqlite = SqliteSerdes(element, annotation, repositoryName: repositoryName);
    final generators = List<SerdesGenerator>();
    generators.addAll(rest.generators);
    generators.addAll(sqlite.generators);
    return generators;
  }

  String generateForAnnotatedElement(element, annotation, buildStep) {
    final generators = buildGenerators(element, annotation);

    return generators.fold(List<String>(), (acc, generator) {
      acc.add(generator.generate());
      return acc;
    }).join("\n");
  }

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
