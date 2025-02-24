import 'package:brick_build/builders.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_with_rest_generator.dart';
import 'package:brick_sqlite_generators/builders.dart';
import 'package:build/build.dart';

final _schemaGenerator = OfflineFirstSchemaGenerator();

///
class OfflineFirstMigrationBuilder extends NewMigrationBuilder<ConnectOfflineFirstWithRest> {
  @override
  final schemaGenerator = _schemaGenerator;
}

///
class OfflineFirstSchemaBuilder extends SchemaBuilder<ConnectOfflineFirstWithRest> {
  @override
  final schemaGenerator = _schemaGenerator;
}

///
const offlineFirstGenerator = OfflineFirstWithRestGenerator(
  superAdapterName: 'OfflineFirstWithRest',
  repositoryName: 'OfflineFirstWithRest',
);

/// These functions act as builder factories used by `build.yaml`
Builder offlineFirstAggregateBuilder(_) => const AggregateBuilder(
      requiredImports: [
        "import 'package:brick_offline_first_abstract/annotations.dart';",
        "import 'package:brick_offline_first/brick_offline_first.dart';",
        "import 'package:brick_core/query.dart';",
        "import 'package:brick_sqlite/db.dart';",
      ],
    );

///
Builder offlineFirstAdaptersBuilder(_) =>
    AdapterBuilder<ConnectOfflineFirstWithRest>(offlineFirstGenerator);

///
Builder offlineFirstModelDictionaryBuilder(_) =>
    ModelDictionaryBuilder<ConnectOfflineFirstWithRest>(
      const OfflineFirstModelDictionaryGenerator('Rest'),
      expectedImportRemovals: [
        "import 'package:brick_offline_first_abstract/annotations.dart';",
        'import "package:brick_offline_first_abstract/annotations.dart";',
        "import 'package:brick_offline_first/brick_offline_first.dart';",
        'import "package:brick_offline_first/brick_offline_first.dart";',
      ],
    );

///
Builder offlineFirstNewMigrationBuilder(_) => OfflineFirstMigrationBuilder();

///
Builder offlineFirstSchemaBuilder(_) => OfflineFirstSchemaBuilder();
