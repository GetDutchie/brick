import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_supabase/brick_supabase.dart';

/// Supabase-enabled [OfflineFirstModel]
abstract class OfflineFirstWithSupabaseModel extends OfflineFirstModel with SupabaseModel {}
