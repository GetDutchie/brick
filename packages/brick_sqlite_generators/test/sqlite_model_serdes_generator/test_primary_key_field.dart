// ignore_for_file: overridden_fields

import 'package:brick_sqlite/brick_sqlite.dart';

@SqliteSerializable()
class PrimaryKeyField extends SqliteModel {
  @override
  final int? primaryKey;

  PrimaryKeyField(this.primaryKey);
}
