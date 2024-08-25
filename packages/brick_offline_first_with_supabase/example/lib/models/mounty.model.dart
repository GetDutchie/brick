import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_offline_first_with_supabase_example/models/hat.dart';

@ConnectOfflineFirstWithSupabase()
class Mounty extends OfflineFirstWithSupabaseModel {
  final String? name;

  final String? email;

  final Hat? hat;

  Mounty({
    this.name,
    this.email,
    this.hat,
  });
}
