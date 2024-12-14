import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:brick_offline_first_with_graphql_build/src/offline_first_graphql_generators.dart';
import 'package:source_gen/source_gen.dart';

/// Produces code for `@ConnectOfflineFirstWithGraphQL`
class OfflineFirstWithGraphqlGenerator
    extends OfflineFirstGenerator<ConnectOfflineFirstWithGraphql> {
  /// Produces code for `@ConnectOfflineFirstWithGraphQL`
  const OfflineFirstWithGraphqlGenerator({
    super.repositoryName,
    super.superAdapterName,
  });

  /// Given an [element] and an [annotation], scaffold generators
  @override
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final rest = OfflineFirstGraphqlModelSerdesGenerator(
      element,
      annotation,
      repositoryName: repositoryName,
    );
    final sqlite =
        OfflineFirstSqliteModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
    return <SerdesGenerator>[...rest.generators, ...sqlite.generators];
  }
}
