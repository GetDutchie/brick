import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/offline_queue.dart';
import 'package:brick_offline_first_with_supabase/src/offline_first_with_supabase_model.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sqflite_common/sqlite_api.dart' show DatabaseFactory;
import 'package:supabase/supabase.dart';

/// Ensures the [remoteProvider] is a [SupabaseProvider].
///
/// OfflineFirstWithSupabaseRepository should accept a type argument such as
/// <_RepositoryModel extends OfflineFirstWithSupabaseModel>, however, this causes a type bound
/// error on runtime. The argument should be reintroduced with a future version of the
/// compiler/analyzer.
///
/// Care should be given to attach an offline queue to the provider using the static convenience
/// method [clientQueue].
///
/// ```dart
/// import 'package:sqflite/sqflite.dart' show databaseFactory;
/// import 'package:my_package/brick/brick.g.dart';
///
/// final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
///   databaseFactory: databaseFactory
/// );
/// final provider = SupabaseProvider(
///   SupabaseClient(supabaseUrl, supabaseAnonKey, httpClient: client),
///   modelDictionary: supabaseModelDictionary,
/// );
///
/// class MyRepository extends OfflineFirstWithSupabaseRepository {
///   MyRepository() : super(
///     supabaseProvider: provider,
///     sqliteProvider: SqliteProvider(databaseFactory),
///     memoryCacheProvider: MemoryCacheProvider(),
///     migrations: migrations,
///     offlineRequestQueue: queue,
///   );
/// }
/// ```
abstract class OfflineFirstWithSupabaseRepository
    extends OfflineFirstRepository<OfflineFirstWithSupabaseModel> {
  /// The type declaration is important here for the rare circumstances that
  /// require interfacting with [SupabaseProvider]'s client directly.
  @override
  // ignore: overridden_fields
  final SupabaseProvider remoteProvider;

  /// In most cases, this queue can be generated using [clientQueue].
  @protected
  final RestOfflineRequestQueue offlineRequestQueue;

  OfflineFirstWithSupabaseRepository({
    super.autoHydrate,
    super.loggerName,
    super.memoryCacheProvider,
    required super.migrations,
    required SupabaseProvider supabaseProvider,
    required super.sqliteProvider,
    required this.offlineRequestQueue,
  })  : remoteProvider = supabaseProvider,
        super(
          remoteProvider: supabaseProvider,
        );

  @override
  Future<bool> delete<TModel extends OfflineFirstWithSupabaseModel>(
    TModel instance, {
    OfflineFirstDeletePolicy policy = OfflineFirstDeletePolicy.optimisticLocal,
    Query? query,
  }) async {
    try {
      return await super.delete<TModel>(instance, policy: policy, query: query);
    } on PostgrestException catch (e) {
      logger.warning('#delete supabase failure: $e');

      if (policy == OfflineFirstDeletePolicy.requireRemote) {
        throw OfflineFirstException(e);
      }

      return false;
    }
  }

  @override
  Future<List<TModel>> get<TModel extends OfflineFirstWithSupabaseModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    query,
    bool seedOnly = false,
  }) async {
    try {
      return await super.get<TModel>(
        policy: policy,
        query: query,
        seedOnly: seedOnly,
      );
    } on PostgrestException catch (e) {
      logger.warning('#get supabase failure: $e');

      if (policy == OfflineFirstGetPolicy.awaitRemote) {
        throw OfflineFirstException(e);
      }

      return <TModel>[];
    }
  }

  @protected
  @override
  Future<List<TModel>> hydrate<TModel extends OfflineFirstWithSupabaseModel>({
    bool deserializeSqlite = true,
    Query? query,
  }) async {
    try {
      return await super.hydrate<TModel>(deserializeSqlite: deserializeSqlite, query: query);
    } on PostgrestException catch (e) {
      logger.warning('#hydrate supabase failure: $e');
    }

    return <TModel>[];
  }

  @override
  @mustCallSuper
  Future<void> initialize() async {
    await super.initialize();
    offlineRequestQueue.start();
  }

  @override
  @mustCallSuper
  Future<void> migrate() async {
    await super.migrate();

    // Migrate cached jobs schema
    await offlineRequestQueue.client.requestManager.migrate();
  }

  @override
  Future<TModel> upsert<TModel extends OfflineFirstWithSupabaseModel>(
    TModel instance, {
    OfflineFirstUpsertPolicy policy = OfflineFirstUpsertPolicy.optimisticLocal,
    Query? query,
  }) async {
    try {
      return await super.upsert<TModel>(instance, policy: policy, query: query);
    } on PostgrestException catch (e) {
      logger.warning('#upsert supabase failure: $e');

      if (policy == OfflineFirstUpsertPolicy.requireRemote) {
        throw OfflineFirstException(e);
      }

      return instance;
    }
  }

  /// This is a convenience method to create the basic offline client and queue.
  /// The client is used to add offline capabilities to [SupabaseProvider];
  /// the queue is used to add offline to the repository.
  static (RestOfflineQueueClient, RestOfflineRequestQueue) clientQueue({
    required DatabaseFactory databaseFactory,
    http.Client? innerClient,
    Duration? processingInterval,
    List<int> reattemptForStatusCodes = const [
      400,
      401,
      403,
      404,
      405,
      408,
      409,
      429,
      500,
      502,
      503,
      504,
    ],
    bool? serialProcessing,
  }) {
    final client = RestOfflineQueueClient(
      innerClient ?? http.Client(),
      RestRequestSqliteCacheManager(
        'brick_offline_queue.sqlite',
        databaseFactory: databaseFactory,
        processingInterval: processingInterval,
        serialProcessing: serialProcessing,
      ),
      reattemptForStatusCodes: reattemptForStatusCodes,
    );
    return (client, RestOfflineRequestQueue(client: client));
  }
}
