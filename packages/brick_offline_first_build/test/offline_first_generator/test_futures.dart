import 'package:brick_offline_first/brick_offline_first.dart' show OfflineFirstModel;
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Futures> _$FuturesFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return Futures(
    string: data['string'] as Future<String>,
    strings: data['strings'].toList().cast<Future<String>>(),
    futureStrings: data['future_strings'] == null
        ? null
        : data['future_strings']?.toList().cast<String>(),
    assoc: AssocAdapter().fromTest(
      data['assoc'],
      provider: provider,
      repository: repository,
    ),
    assocs: Future.wait<Assoc>(
      data['assocs']
              ?.map(
                (d) => AssocAdapter().fromTest(
                  d,
                  provider: provider,
                  repository: repository,
                ),
              )
              .toList()
              .cast<Future<Assoc>>() ??
          [],
    ),
    futureAssocs: data['future_assocs'] == null
        ? null
        : data['future_assocs']
              ?.map(
                (d) => AssocAdapter().fromTest(
                  d,
                  provider: provider,
                  repository: repository,
                ),
              )
              .toList()
              .cast<Future<Assoc>>(),
  );
}

Future<Map<String, dynamic>> _$FuturesToTest(
  Futures instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'string': instance.string,
    'strings': instance.strings,
    'future_strings': instance.futureStrings,
    'assoc': await AssocAdapter().toTest(
      (await instance.assoc),
      provider: provider,
      repository: repository,
    ),
    'assocs': await Future.wait<Map<String, dynamic>>(
      instance.assocs
          .map(
            (s) => AssocAdapter().toTest(
              s,
              provider: provider,
              repository: repository,
            ),
          )
          .toList(),
    ),
    'future_assocs': await Future.wait<Map<String, dynamic>>(
      instance.futureAssocs
              ?.map(
                (s) async => AssocAdapter().toTest(
                  (await s),
                  provider: provider,
                  repository: repository,
                ),
              )
              .toList() ??
          [],
    ),
  };
}

Future<Futures> _$FuturesFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return Futures(
    string: data['string'] as Future<String>,
    strings: jsonDecode(data['strings']).toList().cast<String>(),
    futureStrings: data['future_strings'] == null
        ? null
        : jsonDecode(data['future_strings']).toList().cast<Future<String>>(),
    assoc: repository
        .getAssociation<Assoc>(
          Query.where(
            'primaryKey',
            data['assoc_Assoc_brick_id'] as int,
            limit1: true,
          ),
        )
        .then((r) => r!.first),
    assocs: provider
        .rawQuery(
          'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_Futures_assocs` WHERE l_Futures_brick_id = ?',
          [data['_brick_id'] as int],
        )
        .then((results) {
          final ids = results.map((r) => r['f_Assoc_brick_id']);
          return Future.wait<Assoc>(
            ids.map(
              (primaryKey) async => await repository
                  .getAssociation<Assoc>(
                    Query.where('primaryKey', primaryKey, limit1: true),
                  )
                  .then((r) => r!.first),
            ),
          );
        }),
    futureAssocs: await provider
        .rawQuery(
          'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_Futures_future_assocs` WHERE l_Futures_brick_id = ?',
          [data['_brick_id'] as int],
        )
        .then((results) {
          final ids = results.map((r) => r['f_Assoc_brick_id']);
          return Future.wait<Assoc>(
            ids.map(
              (primaryKey) => repository
                  .getAssociation<Assoc>(
                    Query.where('primaryKey', primaryKey, limit1: true),
                  )
                  .then((r) => r!.first),
            ),
          );
        }),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$FuturesToSqlite(
  Futures instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'string': instance.string,
    'strings': jsonEncode(instance.strings),
    'future_strings': jsonEncode(
      await Future.wait<String>(instance.futureStrings) ?? [],
    ),
    'assoc_Assoc_brick_id':
        (await instance.assoc).primaryKey ??
        await provider.upsert<Assoc>(
          (await instance.assoc),
          repository: repository,
        ),
  };
}

/// Construct a [Futures]
class FuturesAdapter extends OfflineFirstAdapter<Futures> {
  FuturesAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'string': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'string',
      iterable: false,
      type: String,
    ),
    'strings': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'strings',
      iterable: false,
      type: String,
    ),
    'futureStrings': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'future_strings',
      iterable: true,
      type: String,
    ),
    'assoc': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'assoc',
      iterable: false,
      type: Assoc,
    ),
    'assocs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'assocs',
      iterable: false,
      type: Assoc,
    ),
    'futureAssocs': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'future_assocs',
      iterable: true,
      type: Assoc,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    Futures instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'Futures';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      final futureAssocsOldColumns = await provider.rawQuery(
        'SELECT `f_Assoc_brick_id` FROM `_brick_Futures_future_assocs` WHERE `l_Futures_brick_id` = ?',
        [instance.primaryKey],
      );
      final futureAssocsOldIds = futureAssocsOldColumns.map(
        (a) => a['f_Assoc_brick_id'],
      );
      final futureAssocsNewIds =
          instance.futureAssocs?.map((s) => s.primaryKey).whereType<int>() ??
          [];
      final futureAssocsIdsToDelete = futureAssocsOldIds.where(
        (id) => !futureAssocsNewIds.contains(id),
      );

      await Future.wait<void>(
        futureAssocsIdsToDelete.map((id) async {
          return await provider
              .rawExecute(
                'DELETE FROM `_brick_Futures_future_assocs` WHERE `l_Futures_brick_id` = ? AND `f_Assoc_brick_id` = ?',
                [instance.primaryKey, id],
              )
              .catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.futureAssocs?.map((s) async {
              final id =
                  (await s).primaryKey ??
                  await provider.upsert<Assoc>(
                    (await s),
                    repository: repository,
                  );
              return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_Futures_future_assocs` (`l_Futures_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id],
              );
            }) ??
            [],
      );
    }
  }

  @override
  Future<Futures> fromTest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$FuturesFromTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toTest(
    Futures input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async =>
      await _$FuturesToTest(input, provider: provider, repository: repository);
  @override
  Future<Futures> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$FuturesFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    Futures input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$FuturesToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

@ConnectOfflineFirstWithRest()
class Futures extends OfflineFirstModel {
  Futures({
    required this.string,
    required this.strings,
    this.futureStrings,
    required this.assoc,
    required this.assocs,
    this.futureAssocs,
  });

  final Future<String> string;

  final Future<List<String>> strings;

  final List<Future<String>>? futureStrings;

  final Future<Assoc> assoc;

  final Future<List<Assoc>> assocs;

  final List<Future<Assoc>>? futureAssocs;
}

@ConnectOfflineFirstWithRest()
class Assoc extends OfflineFirstModel {}
