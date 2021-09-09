// ignore_for_file: overridden_fields

import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';

@SqliteSerializable()
class PrimaryKeyField extends SqliteModel {
  @override
  final int? primaryKey;

  PrimaryKeyField(this.primaryKey);
}
