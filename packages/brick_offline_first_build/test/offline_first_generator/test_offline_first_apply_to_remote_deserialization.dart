import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<OfflineFirstWhere> _$OfflineFirstWhereFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return OfflineFirstWhere(
    applied: data['applied'] == null
        ? null
        : await repository
              ?.getAssociation<Assoc>(
                Query(where: [Where.exact('id', data['id'])], limit: 1),
              )
              .then((r) => r?.isNotEmpty ?? false ? r!.first : null),
    notApplied: data['not_applied'] == null
        ? null
        : await OtherAssocAdapter().fromTest(
            data['not_applied'],
            provider: provider,
            repository: repository,
          ),
  );
}

Future<Map<String, dynamic>> _$OfflineFirstWhereToTest(
  OfflineFirstWhere instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'applied': "Going to REST", 'not_applied': instance.notApplied?.id};
}

Future<OfflineFirstWhere> _$OfflineFirstWhereFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return OfflineFirstWhere(
    applied: data['applied_Assoc_brick_id'] == null
        ? null
        : (data['applied_Assoc_brick_id'] > -1
              ? (await repository?.getAssociation<Assoc>(
                  Query.where(
                    'primaryKey',
                    data['applied_Assoc_brick_id'] as int,
                    limit1: true,
                  ),
                ))?.first
              : null),
    notApplied: data['not_applied_OtherAssoc_brick_id'] == null
        ? null
        : (data['not_applied_OtherAssoc_brick_id'] > -1
              ? (await repository?.getAssociation<OtherAssoc>(
                  Query.where(
                    'primaryKey',
                    data['not_applied_OtherAssoc_brick_id'] as int,
                    limit1: true,
                  ),
                ))?.first
              : null),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OfflineFirstWhereToSqlite(
  OfflineFirstWhere instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'applied_Assoc_brick_id': instance.applied != null
        ? instance.applied!.primaryKey ??
              await provider.upsert<Assoc>(
                instance.applied!,
                repository: repository,
              )
        : null,
    'not_applied_OtherAssoc_brick_id': instance.notApplied != null
        ? instance.notApplied!.primaryKey ??
              await provider.upsert<OtherAssoc>(
                instance.notApplied!,
                repository: repository,
              )
        : null,
  };
}

/// Construct a [OfflineFirstWhere]
class OfflineFirstWhereAdapter extends OfflineFirstAdapter<OfflineFirstWhere> {
  OfflineFirstWhereAdapter();

  @override
  final fieldsToOfflineFirstRuntimeDefinition =
      <String, RuntimeOfflineFirstDefinition>{
        'applied': const RuntimeOfflineFirstDefinition(
          where: <String, String>{'id': "data['id']"},
        ),
        'notApplied': const RuntimeOfflineFirstDefinition(
          where: <String, String>{'id': "data['id']"},
        ),
      };
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'applied': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'applied_Assoc_brick_id',
      iterable: false,
      type: Assoc,
    ),
    'notApplied': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'not_applied_OtherAssoc_brick_id',
      iterable: false,
      type: OtherAssoc,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    OfflineFirstWhere instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'OfflineFirstWhere';

  @override
  Future<OfflineFirstWhere> fromTest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OfflineFirstWhereFromTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toTest(
    OfflineFirstWhere input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OfflineFirstWhereToTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<OfflineFirstWhere> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OfflineFirstWhereFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    OfflineFirstWhere input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OfflineFirstWhereToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

@ConnectOfflineFirstWithRest()
class OfflineFirstWhere extends OfflineFirstModel {
  OfflineFirstWhere({
    this.applied,
    this.notApplied,
  });

  @OfflineFirst(where: {'id': "data['id']"})
  @Rest(toGenerator: '"Going to REST"')
  final Assoc? applied;

  @OfflineFirst(where: {'id': "data['id']"}, applyToRemoteDeserialization: false)
  final OtherAssoc? notApplied;
}

@ConnectOfflineFirstWithRest()
class Assoc extends OfflineFirstModel {
  final String? name;
  Assoc({this.name});
}

@ConnectOfflineFirstWithRest()
class OtherAssoc extends OfflineFirstModel {
  final String? name;
  OtherAssoc({this.name});
}
