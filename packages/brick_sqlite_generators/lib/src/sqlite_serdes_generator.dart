import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/db.dart' show InsertForeignKey;
import 'package:brick_sqlite_abstract/sqlite_model.dart';
import 'package:meta/meta.dart';

import 'sqlite_fields.dart';

abstract class SqliteSerdesGenerator<_Model extends SqliteModel>
    extends SerdesGenerator<Sqlite, _Model> {
  @override
  final providerName = 'Sqlite';

  @override
  final String repositoryName;

  SqliteSerdesGenerator(
    ClassElement element,
    SqliteFields fields, {
    @required this.repositoryName,
  }) : super(element, fields);

  /// Generate foreign key column if the type is a sibling;
  /// otherwise, return the field's annotated name;
  @override
  String providerNameForField(annotatedName, {checker}) {
    if (checker.isSibling) {
      return InsertForeignKey.foreignKeyColumnName(
          checker.unFuturedType.getDisplayString(), annotatedName);
    }

    return annotatedName;
  }
}
