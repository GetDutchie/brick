import 'package:brick_offline_first_build/src/offline_first_checker.dart';
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite_generators/generators.dart';
import 'package:meta/meta.dart';

@visibleForTesting
@protected
class OfflineFirstSchemaGenerator extends SqliteSchemaGenerator {
  @override
  OfflineFirstChecker checkerForType(type) => OfflineFirstChecker(type);

  @override
  SchemaColumn? schemaColumn(column, {required covariant OfflineFirstChecker checker}) {
    if (checker.hasSerdes) {
      final sqliteSerializerType = checker.superClassTypeArgs[1];
      final sqliteChecker = checkerForType(sqliteSerializerType);
      return SchemaColumn(
        column.name!,
        Migration.fromDartPrimitive(sqliteChecker.asPrimitive),
        nullable: column.nullable,
        unique: column.unique,
      );
    }

    return super.schemaColumn(column, checker: checker);
  }
}
