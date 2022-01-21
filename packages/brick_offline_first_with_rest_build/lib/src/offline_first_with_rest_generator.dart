import 'package:analyzer/dart/element/element.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_rest_generators.dart';
import 'package:brick_build/generators.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_offline_first_abstract/annotations.dart';

class OfflineFirstWithRestGenerator extends OfflineFirstGenerator<ConnectOfflineFirstWithRest> {
  const OfflineFirstWithRestGenerator({
    String? repositoryName,
    String? superAdapterName,
  }) : super(
          repositoryName: repositoryName ?? 'OfflineFirstWithRest',
          superAdapterName: superAdapterName ?? 'OfflineFirstWithRest',
        );

  /// Given an [element] and an [annotation], scaffold generators
  @override
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final rest =
        OfflineFirstRestModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
    final sqlite =
        OfflineFirstSqliteModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
    final generators = <SerdesGenerator>[];
    generators.addAll(rest.generators);
    generators.addAll(sqlite.generators);
    return generators;
  }
}
