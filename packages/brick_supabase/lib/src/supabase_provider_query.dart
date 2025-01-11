import 'package:brick_core/core.dart';
import 'package:brick_supabase/src/supabase_provider.dart';

/// [SupabaseProvider]-specific options for a [Query]
class SupabaseProviderQuery extends ProviderQuery<SupabaseProvider> {
  /// An internal definition for remote requests.
  /// In rare cases, a specific `update` or `insert` is preferable to `upsert`;
  /// this enum explicitly declares the desired behavior.
  final UpsertMethod? upsertMethod;

  /// [SupabaseProvider]-specific options for a [Query]
  const SupabaseProviderQuery({
    this.upsertMethod,
  });

  @override
  Map<String, dynamic> toJson() => {
        if (upsertMethod != null) 'upsertMethod': upsertMethod?.name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupabaseProviderQuery &&
          runtimeType == other.runtimeType &&
          upsertMethod == other.upsertMethod;

  @override
  int get hashCode => upsertMethod.hashCode;
}
