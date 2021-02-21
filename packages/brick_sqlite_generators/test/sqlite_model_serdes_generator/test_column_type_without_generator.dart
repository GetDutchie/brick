import 'dart:io';
import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';

@SqliteSerializable()
class ColumnTypeWithoutGenerator extends SqliteModel {
  @Sqlite(columnType: Column.Double, toGenerator: '%INSTANCE_PROPERTY%')
  final File field;

  ColumnTypeWithoutGenerator(this.field);
}
