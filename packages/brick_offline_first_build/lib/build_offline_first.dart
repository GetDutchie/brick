import 'package:brick_build/src/builders/adapter_builder.dart';
import 'package:brick_build/src/builders/aggregate_builder.dart';
import 'package:brick_build/src/builders/model_dictionary_builder.dart';
import 'package:brick_sqlite_build/src/builders/new_migration_builder.dart';
import 'package:brick_sqlite_build/src/builders/sqlite_schema_builder.dart';
import 'package:brick_offline_first_build/src/offline_first_generator.dart';
import 'package:brick_offline_first_build/src/offline_first_model_dictionary_generator.dart';
import 'package:brick_offline_first_abstract/annotations.dart' show ConnectOfflineFirstWithRest;
import 'package:build/build.dart';

final offlineFirstGenerator = const OfflineFirstGenerator(
  superAdapterName: 'OfflineFirstWithRest',
  repositoryName: 'OfflineFirstWithRest',
);

Builder offlineFirstAggregateBuilder(options) => AggregateBuilder(requiredImports: [
      "import 'package:brick_offline_first_abstract/annotations.dart';",
      "import 'package:brick_offline_first/offline_first.dart';",
      "import 'package:brick_sqlite_abstract/db.dart';",
    ]);
Builder offlineFirstAdaptersBuilder(options) =>
    AdapterBuilder<ConnectOfflineFirstWithRest>(offlineFirstGenerator);
Builder offlineFirstModelDictionaryBuilder(options) =>
    ModelDictionaryBuilder<ConnectOfflineFirstWithRest>(
      const OfflineFirstModelDictionaryGenerator(),
      expectedImportRemovals: [
        "import 'package:brick_offline_first_abstract/annotations.dart';",
        'import "package:brick_offline_first_abstract/annotations.dart";',
        "import 'package:brick_offline_first/offline_first.dart';",
        'import "package:brick_offline_first/offline_first.dart";',
      ],
    );
Builder offlineFirstNewMigrationBuilder(options) =>
    NewMigrationBuilder<ConnectOfflineFirstWithRest>();
Builder offlineFirstSchemaBuilder(options) => SchemaBuilder<ConnectOfflineFirstWithRest>();
