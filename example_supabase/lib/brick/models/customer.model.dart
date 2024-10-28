import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  sqliteConfig: SqliteSerializable(nullable: false),
  supabaseConfig: SupabaseSerializable(tableName: 'testModels'),
)
class Customer extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  String id;
  String name;

  Customer({
    required this.id,
    required this.name,
  });
}
