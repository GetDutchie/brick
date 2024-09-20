import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
)
class Customer extends OfflineFirstWithSupabaseModel {
  @Sqlite(unique: true)
  final String id;

  final String? firstName;

  final String? lastName;

  Customer({
    required this.id,
    this.firstName,
    this.lastName,
  });
}
