import 'package:brick_offline_first_with_rest_build/src/offline_first_checker.dart';
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite_build/builders.dart';
import 'package:brick_sqlite_build/generators.dart';
import 'package:brick_offline_first_abstract/annotations.dart' show ConnectOfflineFirstWithRest;
import 'package:meta/meta.dart';

class OfflineFirstMigrationBuilder extends NewMigrationBuilder<ConnectOfflineFirstWithRest> {
  final schemaGenerator = _schemaGenerator;
}

class OfflineFirstSchemaBuilder extends SchemaBuilder<ConnectOfflineFirstWithRest> {
  final schemaGenerator = _schemaGenerator;
}

@visibleForTesting
@protected
class OfflineFirstSchemaGenerator extends SqliteSchemaGenerator {
  @override
  OfflineFirstChecker checkerForType(type) => OfflineFirstChecker(type);

  @override
  SchemaColumn schemaColumn(column, {covariant OfflineFirstChecker checker}) {
    if (checker.hasSerdes) {
      final sqliteSerializerType = checker.superClassTypeArgs[1];
      final sqliteChecker = checkerForType(sqliteSerializerType);
      return SchemaColumn(
        column.name,
        sqliteChecker.asPrimitive,
        nullable: column?.nullable,
        unique: column?.unique,
      );
    }

    return super.schemaColumn(column, checker: checker);
  }
}

final _schemaGenerator = OfflineFirstSchemaGenerator();
