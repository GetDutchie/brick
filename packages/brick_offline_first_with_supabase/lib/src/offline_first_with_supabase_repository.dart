import 'dart:async';

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
abstract class OfflineFirstWithSupabaseRepository<
        TRepositoryModel extends OfflineFirstWithSupabaseModel>
    extends OfflineFirstRepository<TRepositoryModel> {
  /// The type declaration is important here for the rare circumstances that
  /// require interfacting with [SupabaseProvider]'s client directly.
  @override
  // ignore: overridden_fields
  final SupabaseProvider remoteProvider;

  /// In most cases, this queue can be generated using [clientQueue].
  @protected
  final RestOfflineRequestQueue offlineRequestQueue;

  /// Tracks the realtime stream controllers
  @protected
  @visibleForTesting
  final Map<Type, Map<PostgresChangeEvent, Map<Query, StreamController<List<TRepositoryModel>>>>>
      supabaseRealtimeSubscriptions = {};

  /// Ensures the [remoteProvider] is a [SupabaseProvider].
  ///
  /// Care should be given to attach an offline queue to the provider using the static convenience
  /// method [clientQueue].
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
  Future<bool> delete<TModel extends TRepositoryModel>(
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
    } on AuthRetryableFetchException catch (e) {
      logger.warning('#delete supabase failure: $e');
      if (policy == OfflineFirstDeletePolicy.requireRemote) {
        throw OfflineFirstException(e);
      }
    }

    return false;
  }

  @override
  Future<List<TModel>> get<TModel extends TRepositoryModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    Query? query,
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
    } on AuthRetryableFetchException catch (e) {
      logger.warning('#get supabase failure: $e');
      if (policy == OfflineFirstGetPolicy.awaitRemote) {
        throw OfflineFirstException(e);
      }
    }

    return <TModel>[];
  }

  @protected
  @override
  Future<List<TModel>> hydrate<TModel extends TRepositoryModel>({
    bool deserializeSqlite = true,
    Query? query,
  }) async {
    try {
      return await super.hydrate<TModel>(deserializeSqlite: deserializeSqlite, query: query);
    } on PostgrestException catch (e) {
      logger.warning('#hydrate supabase failure: $e');
    } on AuthRetryableFetchException catch (e) {
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
  Future<void> notifySubscriptionsWithLocalData<TModel extends TRepositoryModel>({
    bool notifyWhenEmpty = true,
    Map<Query?, StreamController<List<TRepositoryModel>>>? subscriptionsByQuery,
  }) async {
    final supabaseControllers = supabaseRealtimeSubscriptions[TModel]
        ?.values
        .fold(<Query, StreamController<List<TRepositoryModel>>>{}, (acc, eventMap) {
      acc.addEntries(eventMap.entries);
      return acc;
    });
    await super.notifySubscriptionsWithLocalData<TModel>(
      notifyWhenEmpty: notifyWhenEmpty,
      subscriptionsByQuery: {
        ...?subscriptionsByQuery,
        ...?subscriptions[TModel],
        ...?supabaseControllers,
      },
    );
  }

  /// Supabase's realtime payload only returns unique columns;
  /// the instance must be discovered from these values so it
  /// can be deleted by all providers.
  @protected
  @visibleForOverriding
  @visibleForTesting
  Query queryFromSupabaseDeletePayload(
    Map<String, dynamic> payload, {
    required Map<String, RuntimeSupabaseColumnDefinition> supabaseDefinitions,
  }) {
    final columnsToFields = supabaseDefinitions.entries.fold(<String, String>{}, (acc, entry) {
      acc[entry.value.columnName] = entry.key;
      return acc;
    });

    final fieldsWithValues = payload.entries.fold(<String, dynamic>{}, (acc, entry) {
      if (columnsToFields[entry.key] != null) {
        acc[columnsToFields[entry.key]!] = entry.value;
      }
      return acc;
    });

    return Query(
      where: fieldsWithValues.entries.map((entry) => Where.exact(entry.key, entry.value)).toList(),
      limit: 1,
    );
  }

  @override
  Future<void> reset() async {
    await super.reset();
    for (final subscription in supabaseRealtimeSubscriptions.values) {
      for (final eventType in subscription.values) {
        for (final controller in eventType.values) {
          await controller.close();
        }
      }
    }
    supabaseRealtimeSubscriptions.clear();
  }

  /// Subscribes to realtime updates using
  /// [Supabase channels](https://supabase.com/docs/guides/realtime?queryGroups=language&language=dart).
  /// **This will only work if your Supabase table has realtime enabled.**
  /// Follow [Supabase's documentation](https://supabase.com/docs/guides/realtime?queryGroups=language&language=dart#realtime-api)
  /// to setup your table.
  ///
  /// The resulting stream will also notify for locally-made changes. In an online state, this
  /// will result in duplicate events on the stream - the local copy is updated and notifies
  /// the caller, then the Supabase realtime event is received and notifies the caller again.
  ///
  /// Supabase's channels can
  /// [become expensive quickly](https://supabase.com/docs/guides/realtime/quotas);
  /// please consider scale when utilizing this method.
  ///
  /// See [subscribe] for reactivity without using realtime.
  ///
  /// [eventType] is the triggering remote event.
  ///
  /// [policy] determines how data is fetched (local or remote). When [OfflineFirstGetPolicy.localOnly],
  /// Supabase channels will not be used.
  ///
  /// [query] is an optional query to filter the data. The query **must be** one level -
  /// `Query.where('user', Query.exact('name', 'Tom'))` is invalid but `Query.where('name', 'Tom')`
  /// is valid. The [Compare] operator is limited to a [PostgresChangeFilterType] equivalent. See [SupabaseProvider.queryToPostgresChangeFilter] for more details.
  Stream<List<TModel>> subscribeToRealtime<TModel extends TRepositoryModel>({
    PostgresChangeEvent eventType = PostgresChangeEvent.all,
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.alwaysHydrate,
    Query? query,
    String schema = 'public',
  }) {
    query ??= const Query();

    if (supabaseRealtimeSubscriptions[TModel]?[eventType]?[query] != null) {
      return supabaseRealtimeSubscriptions[TModel]![eventType]![query]!.stream
          as Stream<List<TModel>>;
    }

    final adapter = remoteProvider.modelDictionary.adapterFor[TModel]!;
    if (policy == OfflineFirstGetPolicy.localOnly) {
      return subscribe<TModel>(policy: policy, query: query);
    }

    final channel = remoteProvider.subscribeToRealtime<TModel>(
      eventType: eventType,
      query: query,
      schema: schema,
      callback: (payload) async {
        switch (payload.eventType) {
          // This code path is likely never hit; `PostgresChangeEvent.all` is used
          // to listen to changes but as far as can be determined is not delivered within
          // the payload of the callback.
          //
          // It's handled just in case this behavior changes.
          case PostgresChangeEvent.all:
            final localResults = await sqliteProvider.get<TModel>(repository: this);
            final remoteResults =
                await get<TModel>(query: query, policy: OfflineFirstGetPolicy.awaitRemote);
            final toDelete = localResults.where((r) => !remoteResults.contains(r));

            for (final deletableModel in toDelete) {
              await sqliteProvider.delete<TModel>(deletableModel, repository: this);
              memoryCacheProvider.delete<TModel>(deletableModel, repository: this);
            }

          case PostgresChangeEvent.delete:
            final query = queryFromSupabaseDeletePayload(
              payload.oldRecord,
              supabaseDefinitions: adapter.fieldsToSupabaseColumns,
            );

            if (query.where?.isEmpty ?? true) return;

            final results = await get<TModel>(
              query: query,
              policy: OfflineFirstGetPolicy.localOnly,
              seedOnly: true,
            );
            if (results.isEmpty) return;

            await sqliteProvider.delete<TModel>(results.first, repository: this);
            memoryCacheProvider.delete<TModel>(results.first, repository: this);

          case PostgresChangeEvent.insert || PostgresChangeEvent.update:
            // The supabase payload is not configurable and will not supply associations.
            // For models that have associations, an additional network call must be
            // made to retrieve all scoped data.
            final modelHasAssociations = adapter.fieldsToSupabaseColumns.entries
                .any((entry) => entry.value.association && !entry.value.associationIsNullable);

            if (modelHasAssociations) {
              await get<TModel>(
                query: query,
                policy: OfflineFirstGetPolicy.alwaysHydrate,
                seedOnly: true,
              );

              return;
            }

            final instance = await adapter.fromSupabase(
              payload.newRecord,
              provider: remoteProvider,
              repository: this,
            );

            await sqliteProvider.upsert<TModel>(instance as TModel, repository: this);
            memoryCacheProvider.upsert<TModel>(instance, repository: this);
        }

        await notifySubscriptionsWithLocalData<TModel>();
      },
    );

    final controller = StreamController<List<TModel>>(
      onCancel: () async {
        await channel.unsubscribe();
        await supabaseRealtimeSubscriptions[TModel]?[eventType]?[query]?.close();
        supabaseRealtimeSubscriptions[TModel]?[eventType]?.remove(query);

        if (supabaseRealtimeSubscriptions[TModel]?[eventType]?.isEmpty ?? false) {
          supabaseRealtimeSubscriptions[TModel]?.remove(eventType);
        }

        if (supabaseRealtimeSubscriptions[TModel]?.isEmpty ?? false) {
          supabaseRealtimeSubscriptions.remove(TModel);
        }
      },
    );
    supabaseRealtimeSubscriptions[TModel] ??= {};
    supabaseRealtimeSubscriptions[TModel]![eventType] ??= {};
    supabaseRealtimeSubscriptions[TModel]![eventType]![query] = controller;

    // Fetch initial data
    // ignore: discarded_futures
    get<TModel>(query: query, policy: policy).then((results) {
      if (!controller.isClosed) controller.add(results);
    });

    return controller.stream;
  }

  @override
  Future<TModel> upsert<TModel extends TRepositoryModel>(
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
    } on AuthRetryableFetchException catch (e) {
      logger.warning('#upsert supabase failure: $e');
      if (policy == OfflineFirstUpsertPolicy.requireRemote) {
        throw OfflineFirstException(e);
      }
    }

    return instance;
  }

  /// This is a convenience method to create the basic offline client and queue.
  /// The client is used to add offline capabilities to [SupabaseProvider];
  /// the queue is used to add offline to the repository.
  static (RestOfflineQueueClient, RestOfflineRequestQueue) clientQueue({
    required DatabaseFactory databaseFactory,
    String databasePath = 'brick_offline_queue.sqlite',

    /// These paths will not be stored in the offline queue.
    /// By default, Supabase Auth and Storage paths are ignored.
    ///
    /// For implementations that wish to retry functions and do not
    /// need to handle a response, add `'/functions/v1'` to this Set.
    /// https://github.com/GetDutchie/brick/issues/440
    Set<String>? ignorePaths = const {
      '/auth/v1',
      '/storage/v1',
    },
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
    void Function(http.Request request, int statusCode)? onReattempt,
    void Function(http.Request, Object)? onRequestException,
  }) {
    final client = RestOfflineQueueClient(
      innerClient ?? http.Client(),
      RestRequestSqliteCacheManager(
        databasePath,
        databaseFactory: databaseFactory,
        processingInterval: processingInterval,
        serialProcessing: serialProcessing,
      ),
      ignorePaths: ignorePaths,
      onReattempt: onReattempt,
      onRequestException: onRequestException,
      reattemptForStatusCodes: reattemptForStatusCodes,
    );
    return (client, RestOfflineRequestQueue(client: client));
  }
}
