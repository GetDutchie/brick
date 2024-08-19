import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/src/offline_first_with_supabase_model.dart';
import 'package:brick_supabase/brick_supabase.dart' show SupabaseProvider;

/// Ensures the [remoteProvider] is a [SupabaseProvider].
///
/// OfflineFirstWithSupabaseRepository should accept a type argument such as
/// <_RepositoryModel extends OfflineFirstWithSupabaseModel>, however, this causes a type bound
/// error on runtime. The argument should be reintroduced with a future version of the
/// compiler/analyzer.
abstract class OfflineFirstWithSupabaseRepository
    extends OfflineFirstRepository<OfflineFirstWithSupabaseModel> {
  /// The type declaration is important here for the rare circumstances that
  /// require interfacting with [SupabaseProvider]'s client directly.
  @override
  // ignore: overridden_fields
  final SupabaseProvider remoteProvider;

  OfflineFirstWithSupabaseRepository({
    super.autoHydrate,
    super.loggerName,
    super.memoryCacheProvider,
    required super.migrations,
    required SupabaseProvider supabaseProvider,
    required super.sqliteProvider,
  })  : remoteProvider = supabaseProvider,
        super(
          remoteProvider: supabaseProvider,
        );
}
