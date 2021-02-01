import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';

@SqliteSerializable()
class IdField extends SqliteModel {
  @Sqlite(name: '_brick_id')
  final int someField;

  IdField(this.someField);
}
