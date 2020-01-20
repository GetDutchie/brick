import 'package:brick_offline_first_with_rest_build/src/offline_first_checker.dart';
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite_build/builders.dart';
import 'package:brick_sqlite_build/generators.dart';
import 'package:brick_offline_first_abstract/annotations.dart' show ConnectOfflineFirstWithRest;

class OfflineFirstMigrationBuilder extends NewMigrationBuilder<ConnectOfflineFirstWithRest> {
  final schemaGenerator = _schemaGenerator;
}

class OfflineFirstSchemaBuilder extends SchemaBuilder<ConnectOfflineFirstWithRest> {
  final schemaGenerator = _schemaGenerator;
}

class _OfflineFirstSchemaGenerator extends SqliteSchemaGenerator {
  @override
  columnForField(field, column) {
    final result = super.columnForField(field, column);
    if (result != null) return result;

    var checker = OfflineFirstChecker(field.type);
    final columnName = column.name;
    if (checker.isFuture) {
      checker = OfflineFirstChecker(checker.argType);
    }

    if (!checker.isSerializable) {
      return null;
    }

    if (checker.hasSerdes) {
      final sqliteType = checker.superClassTypeArgs.last;
      final sqliteChecker = OfflineFirstChecker(sqliteType);
      return SchemaColumn(
        columnName,
        sqliteChecker.asPrimitive,
        nullable: column?.nullable,
        unique: column?.unique,
      );
    }

    return null;
  }
}

final _schemaGenerator = _OfflineFirstSchemaGenerator();
