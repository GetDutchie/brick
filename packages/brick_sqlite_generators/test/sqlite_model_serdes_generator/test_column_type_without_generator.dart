import 'dart:io';
import 'package:brick_sqlite/brick_sqlite.dart';

@SqliteSerializable()
class ColumnTypeWithoutGenerator extends SqliteModel {
  @Sqlite(columnType: Column.Double, toGenerator: '%INSTANCE_PROPERTY%')
  final File field;

  ColumnTypeWithoutGenerator(this.field);
}
