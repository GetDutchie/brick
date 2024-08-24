import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_offline_first_with_supabase_example/models/mounty.model.dart';

@ConnectOfflineFirstWithSupabase()
class Horse extends OfflineFirstWithSupabaseModel {
  final String? name;

  final List<Mounty>? mounties;

  Horse({
    this.name,
    this.mounties,
  });
}
