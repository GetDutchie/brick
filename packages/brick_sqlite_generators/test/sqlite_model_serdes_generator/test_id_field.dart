import 'package:brick_sqlite/brick_sqlite.dart';

@SqliteSerializable()
class IdField extends SqliteModel {
  @Sqlite(name: '_brick_id')
  final int someField;

  IdField(this.someField);
}
