import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';

class NonSqliteAssoc {}

const output = r'''
Future<UnreleatedAssociation> _$UnreleatedAssociationFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return UnreleatedAssociation();
}

Future<Map<String, dynamic>> _$UnreleatedAssociationToTest(
  UnreleatedAssociation instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {};
}

Future<UnreleatedAssociation> _$UnreleatedAssociationFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return UnreleatedAssociation()..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$UnreleatedAssociationToSqlite(
  UnreleatedAssociation instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {};
}
''';

@ConnectOfflineFirstWithRest()
class UnreleatedAssociation {
  final NonSqliteAssoc? assoc;

  UnreleatedAssociation({this.assoc});
}
