import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/db.dart' show InsertForeignKey;
import 'package:brick_sqlite_build/src/sqlite_checker.dart';

import 'sqlite_fields.dart';

abstract class SqliteSerdesGenerator extends SerdesGenerator<Sqlite, SqliteChecker> {
  static const SQLITE_PROVIDER_NAME = 'Sqlite';

  final String repositoryName;

  SqliteSerdesGenerator(
    ClassElement element,
    SqliteFields fields, {
    this.repositoryName,
  }) : super(element, fields);

  /// Return an `SqliteChecker` for a field.
  /// If the field is a future type, returns a checker of the arg type.
  @override
  SqliteChecker checkerForField(FieldElement field, {DartType type}) {
    final checker = SqliteChecker(type ?? field.type);
    if (checker.isFuture) {
      return checkerForField(field, type: checker.argType);
    }

    return checker;
  }

  /// Generate foreign key column if the type is a sibling;
  /// otherwise, return the field's annotated name;
  @override
  String providerNameForField(annotatedName, {checker}) {
    if (checker.isSibling && providerName == SQLITE_PROVIDER_NAME) {
      return InsertForeignKey.foreignKeyColumnName(
          checker.unFuturedType.getDisplayString(), annotatedName);
    }

    return annotatedName;
  }
}
