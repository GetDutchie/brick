import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';

const output = r'''
Future<SpecifyFieldName> _$SpecifyFieldNameFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SpecifyFieldName(
    email: data['supa_email_address'] == null
        ? null
        : data['supa_email_address'] as String?,
  );
}

Future<Map<String, dynamic>> _$SpecifyFieldNameToSupabase(
  SpecifyFieldName instance, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'supa_email_address': instance.email};
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

@ConnectOfflineFirstWithSupabase()
class SpecifyFieldName {
  @Sqlite(name: 'email_address')
  @Supabase(name: 'supa_email_address')
  final String? email;

  SpecifyFieldName({this.email});
}
