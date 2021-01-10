import 'package:brick_sqlite/sqlite.dart';
import 'package:brick_sqlite_abstract/annotations.dart';

class DemoModelAssoc extends SqliteModel {
  DemoModelAssoc({this.name});
  final String name;
}

class DemoModel extends SqliteModel {
  DemoModel({
    this.name,
    this.assoc,
    this.complexFieldName,
    this.lastName,
    this.manyAssoc,
    this.simpleBool,
  });

  final DemoModelAssoc assoc;
  final String complexFieldName;
  final String lastName;
  final List<DemoModelAssoc> manyAssoc;

  @Sqlite(name: 'full_name')
  final String name;
  final bool simpleBool;
}
