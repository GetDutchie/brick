import 'package:brick_core/core.dart';
import 'package:brick_supabase/src/supabase_adapter.dart';
import 'package:brick_supabase_abstract/brick_supabase_abstract.dart';

/// Associates app models with their [SupabaseAdapter]
class SupabaseModelDictionary
    extends ModelDictionary<SupabaseModel, SupabaseAdapter<SupabaseModel>> {
  const SupabaseModelDictionary(super.adapterFor);
}
