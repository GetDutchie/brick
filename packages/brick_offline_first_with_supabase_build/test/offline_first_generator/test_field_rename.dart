import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

const output = r'''
Future<SupabaseDefault> _$SupabaseDefaultFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseDefault(someLongField: data['some_long_field'] as int);
}

Future<Map<String, dynamic>> _$SupabaseDefaultToSupabase(
  SupabaseDefault instance, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<SupabaseDefault> _$SupabaseDefaultFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseDefault(someLongField: data['some_long_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SupabaseDefaultToSqlite(
  SupabaseDefault instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<SupabaseNoRename> _$SupabaseNoRenameFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseNoRename(someLongField: data['someLongField'] as int);
}

Future<Map<String, dynamic>> _$SupabaseNoRenameToSupabase(
  SupabaseNoRename instance, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'someLongField': instance.someLongField};
}

Future<SupabaseNoRename> _$SupabaseNoRenameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseNoRename(someLongField: data['some_long_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SupabaseNoRenameToSqlite(
  SupabaseNoRename instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<SupabaseSnakeRename> _$SupabaseSnakeRenameFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseSnakeRename(someLongField: data['some_long_field'] as int);
}

Future<Map<String, dynamic>> _$SupabaseSnakeRenameToSupabase(
  SupabaseSnakeRename instance, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<SupabaseSnakeRename> _$SupabaseSnakeRenameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseSnakeRename(someLongField: data['some_long_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SupabaseSnakeRenameToSqlite(
  SupabaseSnakeRename instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<SupabaseKebabRename> _$SupabaseKebabRenameFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseKebabRename(someLongField: data['some-long-field'] as int);
}

Future<Map<String, dynamic>> _$SupabaseKebabRenameToSupabase(
  SupabaseKebabRename instance, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some-long-field': instance.someLongField};
}

Future<SupabaseKebabRename> _$SupabaseKebabRenameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseKebabRename(someLongField: data['some_long_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SupabaseKebabRenameToSqlite(
  SupabaseKebabRename instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<SupabasePascalRename> _$SupabasePascalRenameFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabasePascalRename(someLongField: data['SomeLongField'] as int);
}

Future<Map<String, dynamic>> _$SupabasePascalRenameToSupabase(
  SupabasePascalRename instance, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'SomeLongField': instance.someLongField};
}

Future<SupabasePascalRename> _$SupabasePascalRenameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabasePascalRename(someLongField: data['some_long_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SupabasePascalRenameToSqlite(
  SupabasePascalRename instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<SupabaseRenameWithOverride> _$SupabaseRenameWithOverrideFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseRenameWithOverride(someLongField: data['some_field'] as int);
}

Future<Map<String, dynamic>> _$SupabaseRenameWithOverrideToSupabase(
  SupabaseRenameWithOverride instance, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_field': instance.someLongField};
}

Future<SupabaseRenameWithOverride> _$SupabaseRenameWithOverrideFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseRenameWithOverride(
    someLongField: data['some_long_field'] as int,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SupabaseRenameWithOverrideToSqlite(
  SupabaseRenameWithOverride instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}
''';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable.defaults,
)
class SupabaseDefault extends OfflineFirstModel {
  final int someLongField;

  SupabaseDefault(this.someLongField);
}

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(fieldRename: FieldRename.none),
)
class SupabaseNoRename extends OfflineFirstModel {
  final int someLongField;

  SupabaseNoRename(this.someLongField);
}

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable.defaults,
)
class SupabaseSnakeRename extends OfflineFirstModel {
  final int someLongField;

  SupabaseSnakeRename(this.someLongField);
}

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(fieldRename: FieldRename.kebab),
)
class SupabaseKebabRename extends OfflineFirstModel {
  final int someLongField;

  SupabaseKebabRename(this.someLongField);
}

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(fieldRename: FieldRename.pascal),
)
class SupabasePascalRename extends OfflineFirstModel {
  final int someLongField;

  SupabasePascalRename(this.someLongField);
}

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(fieldRename: FieldRename.pascal),
)
class SupabaseRenameWithOverride extends OfflineFirstModel {
  @Supabase(name: 'some_field')
  final int someLongField;

  SupabaseRenameWithOverride(this.someLongField);
}
