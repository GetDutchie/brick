import 'package:brick_sqlite/brick_sqlite.dart';

final output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<AfterSaveWithAssociation> _$AfterSaveWithAssociationFromSqlite(
    Map<String, dynamic> data,
    {required SqliteProvider provider,
    SqliteFirstRepository? repository}) async {
  return AfterSaveWithAssociation()..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$AfterSaveWithAssociationToSqlite(
    AfterSaveWithAssociation instance,
    {required SqliteProvider provider,
    SqliteFirstRepository? repository}) async {
  return {};
}

/// Construct a [AfterSaveWithAssociation]
class AfterSaveWithAssociationAdapter
    extends SqliteAdapter<AfterSaveWithAssociation> {
  AfterSaveWithAssociationAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
          AfterSaveWithAssociation instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'AfterSaveWithAssociation';

  @override
  Future<AfterSaveWithAssociation> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant SqliteRepository? repository}) async =>
      await _$AfterSaveWithAssociationFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(AfterSaveWithAssociation input,
          {required provider, covariant SqliteRepository? repository}) async =>
      await _$AfterSaveWithAssociationToSqlite(input,
          provider: provider, repository: repository);
}
""";

class Assoc extends SqliteModel {
  final String someField;

  Assoc(this.someField);
}

@SqliteSerializable()
class AfterSaveWithAssociation extends SqliteModel {
  @Sqlite(ignore: true)
  final List<Assoc> ignoredAssocs;

  AfterSaveWithAssociation({
    this.ignoredAssocs = const <Assoc>[],
  });
}
