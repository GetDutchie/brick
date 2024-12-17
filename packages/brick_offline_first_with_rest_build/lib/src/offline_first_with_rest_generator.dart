import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_rest_generators.dart';
import 'package:source_gen/source_gen.dart';

///
class OfflineFirstWithRestGenerator extends OfflineFirstGenerator<ConnectOfflineFirstWithRest> {
  ///
  const OfflineFirstWithRestGenerator({
    super.repositoryName,
    super.superAdapterName,
  });

  /// Given an [element] and an [annotation], scaffold generators
  @override
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final rest =
        OfflineFirstRestModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
    final sqlite =
        OfflineFirstSqliteModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
    return <SerdesGenerator>[...rest.generators, ...sqlite.generators];
  }
}
