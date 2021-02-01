import 'dart:convert';

import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_sqlite_abstract/db.dart';

// Existing migration
const List<MigrationCommand> _migration_1_up = [
  InsertTable('Serdes'),
  InsertTable('WithSerdes'),
  InsertColumn('name', Column.varchar, onTable: 'Serdes'),
  InsertColumn('serdes_member', Column.varchar, onTable: 'WithSerdes')
];
const List<MigrationCommand> _migration_1_down = [
  DropTable('Serdes'),
  DropTable('WithSerdes'),
  DropColumn('name', onTable: 'Serdes'),
  DropColumn('serdes_member', onTable: 'WithSerdes')
];

@Migratable(version: '1', up: _migration_1_up, down: _migration_1_down)
class Migration1 extends Migration {
  const Migration1() : super(version: 1, up: _migration_1_up, down: _migration_1_down);
}

// serdes definition
@ConnectOfflineFirstWithRest()
class Serdes extends OfflineFirstSerdes<Map<String, dynamic>, String> {
  final String name;

  Serdes({this.name});

  factory Serdes.fromRest(Map<String, dynamic> data) {
    return Serdes(name: data['name']);
  }

  factory Serdes.fromSqlite(String data) => Serdes.fromRest(jsonDecode(data));

  @override
  Map<String, dynamic> toRest() {
    return {
      'name': name,
    };
  }

  @override
  String toSqlite() => jsonEncode(toRest());
}

// model to receive new migration
@ConnectOfflineFirstWithRest()
class WithSerdes extends OfflineFirstWithRestModel {
  final Serdes serdesMember;

  final Serdes additionalSerdesMember;

  WithSerdes({
    this.serdesMember,
    this.additionalSerdesMember,
  });
}

final output = r'''
// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_2_up = [
  InsertColumn('additional_serdes_member', Column.varchar, onTable: 'WithSerdes')
];

const List<MigrationCommand> _migration_2_down = [
  DropColumn('additional_serdes_member', onTable: 'WithSerdes')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '2',
  up: _migration_2_up,
  down: _migration_2_down,
)
class Migration2 extends Migration {
  const Migration2()
    : super(
        version: 2,
        up: _migration_2_up,
        down: _migration_2_down,
      );
}
''';
