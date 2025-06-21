import 'package:brick_offline_first/brick_offline_first.dart' show OfflineFirstModel;
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithRest()
class SqliteAssoc extends OfflineFirstModel {
  @Rest(ignore: true)
  @Sqlite(ignore: true)
  int key = -1;
}

const output = r'''
Future<SqliteAssoc> _$SqliteAssocFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SqliteAssoc();
}

Future<Map<String, dynamic>> _$SqliteAssocToTest(
  SqliteAssoc instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {};
}

Future<SqliteAssoc> _$SqliteAssocFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SqliteAssoc()..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SqliteAssocToSqlite(
  SqliteAssoc instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {};
}

Future<OneToOneAssociation> _$OneToOneAssociationFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return OneToOneAssociation(
    nullableAssoc: data['nullable_assoc'] == null
        ? null
        : await SqliteAssocAdapter().fromTest(
            data['nullable_assoc'],
            provider: provider,
            repository: repository,
          ),
    nullableAssoc2: data['nullable_assoc2'] == null
        ? null
        : await SqliteAssocAdapter().fromTest(
            data['nullable_assoc2'],
            provider: provider,
            repository: repository,
          ),
    assoc: await SqliteAssocAdapter().fromTest(
      data['assoc'],
      provider: provider,
      repository: repository,
    ),
    assoc2: await SqliteAssocAdapter().fromTest(
      data['assoc2'],
      provider: provider,
      repository: repository,
    ),
  );
}

Future<Map<String, dynamic>> _$OneToOneAssociationToTest(
  OneToOneAssociation instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'nullable_assoc': instance.nullableAssoc != null
        ? await SqliteAssocAdapter().toTest(
            instance.nullableAssoc!,
            provider: provider,
            repository: repository,
          )
        : null,
    'nullable_assoc2': instance.nullableAssoc2 != null
        ? await SqliteAssocAdapter().toTest(
            instance.nullableAssoc2!,
            provider: provider,
            repository: repository,
          )
        : null,
    'assoc': await SqliteAssocAdapter().toTest(
      instance.assoc,
      provider: provider,
      repository: repository,
    ),
    'assoc2': await SqliteAssocAdapter().toTest(
      instance.assoc2,
      provider: provider,
      repository: repository,
    ),
  };
}

Future<OneToOneAssociation> _$OneToOneAssociationFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return OneToOneAssociation(
    nullableAssoc: data['nullable_assoc_SqliteAssoc_brick_id'] == null
        ? null
        : (data['nullable_assoc_SqliteAssoc_brick_id'] > -1
              ? (await repository?.getAssociation<SqliteAssoc>(
                  Query.where(
                    'primaryKey',
                    data['nullable_assoc_SqliteAssoc_brick_id'] as int,
                    limit1: true,
                  ),
                ))?.first
              : null),
    nullableAssoc2: data['nullable_assoc2_SqliteAssoc_brick_id'] == null
        ? null
        : (data['nullable_assoc2_SqliteAssoc_brick_id'] > -1
              ? (await repository?.getAssociation<SqliteAssoc>(
                  Query.where(
                    'primaryKey',
                    data['nullable_assoc2_SqliteAssoc_brick_id'] as int,
                    limit1: true,
                  ),
                ))?.first
              : null),
    assoc: (await repository!.getAssociation<SqliteAssoc>(
      Query.where(
        'primaryKey',
        data['assoc_SqliteAssoc_brick_id'] as int,
        limit1: true,
      ),
    ))!.first,
    assoc2: (await repository.getAssociation<SqliteAssoc>(
      Query.where(
        'primaryKey',
        data['assoc2_SqliteAssoc_brick_id'] as int,
        limit1: true,
      ),
    ))!.first,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OneToOneAssociationToSqlite(
  OneToOneAssociation instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'nullable_assoc_SqliteAssoc_brick_id': instance.nullableAssoc != null
        ? instance.nullableAssoc!.primaryKey ??
              await provider.upsert<SqliteAssoc>(
                instance.nullableAssoc!,
                repository: repository,
              )
        : null,
    'nullable_assoc2_SqliteAssoc_brick_id': instance.nullableAssoc2 != null
        ? instance.nullableAssoc2!.primaryKey ??
              await provider.upsert<SqliteAssoc>(
                instance.nullableAssoc2!,
                repository: repository,
              )
        : null,
    'assoc_SqliteAssoc_brick_id':
        instance.assoc.primaryKey ??
        await provider.upsert<SqliteAssoc>(
          instance.assoc,
          repository: repository,
        ),
    'assoc2_SqliteAssoc_brick_id':
        instance.assoc2.primaryKey ??
        await provider.upsert<SqliteAssoc>(
          instance.assoc2,
          repository: repository,
        ),
  };
}
''';

@ConnectOfflineFirstWithRest()
class OneToOneAssociation extends OfflineFirstModel {
  OneToOneAssociation({
    this.nullableAssoc,
    this.nullableAssoc2,
    required this.assoc,
    required this.assoc2,
  });

  final SqliteAssoc? nullableAssoc;
  final SqliteAssoc? nullableAssoc2;

  final SqliteAssoc assoc;
  final SqliteAssoc assoc2;
}
