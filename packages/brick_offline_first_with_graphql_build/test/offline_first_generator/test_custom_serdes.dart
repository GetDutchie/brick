import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

const output = r'''
Future<CustomSerdes> _$CustomSerdesFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return CustomSerdes(
    string: data['string'] == null
        ? null
        : data['string'].split('').map((s) => '$s.1').join(''),
  );
}

Future<Map<String, dynamic>> _$CustomSerdesToGraphql(
  CustomSerdes instance, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'string': instance.string};
}

Future<CustomSerdes> _$CustomSerdesFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return CustomSerdes(
    string: data['string'] == null ? null : data['string'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CustomSerdesToSqlite(
  CustomSerdes instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'string': instance.string.substring(0, 1)};
}
''';

@ConnectOfflineFirstWithGraphql()
class CustomSerdes {
  @Graphql(fromGenerator: r"data['string'].split('').map((s) => '$s.1').join('')")
  @Sqlite(toGenerator: 'instance.string.substring(0, 1)')
  final String? string;

  CustomSerdes({
    this.string,
  });
}
