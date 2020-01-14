import 'package:brick_offline_first_abstract/annotations.dart';

class NonSqliteAssoc {}

final output = r'''
Future<UnreleatedAssociation> _$UnreleatedAssociationFromRest(
    Map<String, dynamic> data,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return UnreleatedAssociation();
}

Future<Map<String, dynamic>> _$UnreleatedAssociationToRest(
    UnreleatedAssociation instance,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return {};
}

Future<UnreleatedAssociation> _$UnreleatedAssociationFromSqlite(
    Map<String, dynamic> data,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return UnreleatedAssociation()..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$UnreleatedAssociationToSqlite(
    UnreleatedAssociation instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {};
}
''';

@ConnectOfflineFirstWithRest()
class UnreleatedAssociation {
  UnreleatedAssociation({this.assoc});

  final NonSqliteAssoc assoc;
}
