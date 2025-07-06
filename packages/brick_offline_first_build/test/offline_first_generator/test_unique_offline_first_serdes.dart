import 'package:brick_offline_first/brick_offline_first.dart' show OfflineFirstSerdes;
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

const output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<CustomOfflineFirstSerdes> _$CustomOfflineFirstSerdesFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return CustomOfflineFirstSerdes(
    string: data['string'] == null
        ? null
        : Serializable.fromTest(data['string']),
  );
}

Future<Map<String, dynamic>> _$CustomOfflineFirstSerdesToTest(
  CustomOfflineFirstSerdes instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'string': instance.string?.toTest()};
}

Future<CustomOfflineFirstSerdes> _$CustomOfflineFirstSerdesFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return CustomOfflineFirstSerdes(
    string: data['string'] == null
        ? null
        : Serializable.fromSqlite(data['string'] as int),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CustomOfflineFirstSerdesToSqlite(
  CustomOfflineFirstSerdes instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {};
}

/// Construct a [CustomOfflineFirstSerdes]
class CustomOfflineFirstSerdesAdapter
    extends OfflineFirstAdapter<CustomOfflineFirstSerdes> {
  CustomOfflineFirstSerdesAdapter();

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
      type: Serializable,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    CustomOfflineFirstSerdes instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `CustomOfflineFirstSerdes` WHERE string = ? LIMIT 1''',
      [instance.string.toSqlite()],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'CustomOfflineFirstSerdes';

  @override
  Future<CustomOfflineFirstSerdes> fromTest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$CustomOfflineFirstSerdesFromTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toTest(
    CustomOfflineFirstSerdes input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$CustomOfflineFirstSerdesToTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<CustomOfflineFirstSerdes> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$CustomOfflineFirstSerdesFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    CustomOfflineFirstSerdes input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$CustomOfflineFirstSerdesToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
""";

class Serializable extends OfflineFirstSerdes<Map<String, dynamic>, int> {
  final int age;
  Serializable(this.age);

  Map<String, dynamic> toTest() => {'age': '$age'};

  factory Serializable.fromTest(Map<String, dynamic> data) {
    return Serializable(data['age']);
  }

  factory Serializable.fromSqlite(age) {
    return Serializable(age);
  }
}

@ConnectOfflineFirstWithRest()
class CustomOfflineFirstSerdes {
  CustomOfflineFirstSerdes({this.string});

  @Sqlite(unique: true)
  final Serializable? string;
}
