import 'package:brick_build/builders.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:brick_offline_first_with_graphql_build/src/offline_first_with_graphql_generator.dart';
import 'package:brick_sqlite_generators/builders.dart';
import 'package:build/build.dart';

final _schemaGenerator = OfflineFirstSchemaGenerator();

class OfflineFirstMigrationBuilder extends NewMigrationBuilder<ConnectOfflineFirstWithGraphql> {
  @override
  final schemaGenerator = _schemaGenerator;
}

class OfflineFirstSchemaBuilder extends SchemaBuilder<ConnectOfflineFirstWithGraphql> {
  @override
  final schemaGenerator = _schemaGenerator;
}

final offlineFirstGenerator = const OfflineFirstWithGraphqlGenerator(
  superAdapterName: 'OfflineFirstWithGraphql',
  repositoryName: 'OfflineFirstWithGraphql',
);

/// These functions act as builder factories used by `build.yaml`
Builder offlineFirstAggregateBuilder(options) => AggregateBuilder(
      requiredImports: [
        "import 'package:brick_offline_first/brick_offline_first.dart';",
        "import 'package:brick_sqlite/db.dart';",
        "import 'package:brick_core/query.dart';",
        "import 'package:brick_graphql/brick_graphql.dart' show RuntimeGraphqlDefinition;",
        "import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart' show OfflineFirstWithGraphqlRepository, OfflineFirstWithGraphqlAdapter;",
      ],
    );
Builder offlineFirstAdaptersBuilder(options) =>
    AdapterBuilder<ConnectOfflineFirstWithGraphql>(offlineFirstGenerator);
Builder offlineFirstModelDictionaryBuilder(options) =>
    ModelDictionaryBuilder<ConnectOfflineFirstWithGraphql>(
      const OfflineFirstModelDictionaryGenerator('Graphql'),
      expectedImportRemovals: [
        "import 'package:brick_offline_first/brick_offline_first.dart';",
        "import 'package:brick_offline_first/brick_offline_first.dart';",
      ],
    );
Builder offlineFirstNewMigrationBuilder(options) => OfflineFirstMigrationBuilder();
Builder offlineFirstSchemaBuilder(options) => OfflineFirstSchemaBuilder();
