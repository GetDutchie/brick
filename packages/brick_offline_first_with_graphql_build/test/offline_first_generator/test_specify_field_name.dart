import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

const output = r'''
Future<SpecifyFieldName> _$SpecifyFieldNameFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SpecifyFieldName(
    email: data['email_address'] == null
        ? null
        : data['email_address'] as String?,
  );
}

Future<Map<String, dynamic>> _$SpecifyFieldNameToGraphql(
  SpecifyFieldName instance, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'email_address': instance.email};
}

Future<SpecifyFieldName> _$SpecifyFieldNameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SpecifyFieldName(
    email: data['email_address'] == null
        ? null
        : data['email_address'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SpecifyFieldNameToSqlite(
  SpecifyFieldName instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'email_address': instance.email};
}
''';

@ConnectOfflineFirstWithGraphql()
class SpecifyFieldName {
  @Sqlite(name: 'email_address')
  @Graphql(name: 'email_address')
  final String? email;

  SpecifyFieldName({this.email});
}
