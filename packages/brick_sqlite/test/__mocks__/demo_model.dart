import 'package:brick_sqlite/brick_sqlite.dart';

class DemoModelAssoc extends SqliteModel {
  DemoModelAssoc({this.name});
  final String? name;
}

class DemoModel extends SqliteModel {
  final DemoModelAssoc? assoc;

  final String? complexFieldName;

  final String? lastName;

  List<DemoModelAssoc>? manyAssoc;

  @Sqlite(name: 'full_name')
  final String? name;

  final bool? simpleBool;

  final DateTime? simpleTime;

  DemoModel({
    this.name,
    this.assoc,
    this.complexFieldName,
    this.lastName,
    this.manyAssoc,
    this.simpleBool,
    this.simpleTime,
  });
}
