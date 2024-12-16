import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/src/offline_first_with_supabase_model.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';

/// This adapter combines logic from [SqliteProvider] and [SupabaseProvider].
abstract class OfflineFirstWithSupabaseAdapter<_Model extends OfflineFirstWithSupabaseModel>
    extends OfflineFirstAdapter<_Model> with SupabaseAdapter<_Model> {
  /// This adapter combines logic from [SqliteProvider] and [SupabaseProvider].
  OfflineFirstWithSupabaseAdapter();
}
