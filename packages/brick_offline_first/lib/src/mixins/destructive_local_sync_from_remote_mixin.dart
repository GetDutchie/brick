import 'package:brick_offline_first/offline_first.dart';

/// Provides an extended `get` method to support remote syncs that override local data.
/// For example, if two models exist in the `remoteProvider` but three exist in `sqliteProvider`
/// and `memoryCacheProvider`, the extra model is removed from the local providers when
/// `#get:forceLocalSyncFromRemote` is true or when [destructiveLocalSyncFromRemote] is invoked.
///
/// Using this mixin and its methods requires that the data from the [remoteProvider]
/// should not be paginated and complete from a single request.
mixin DestructiveLocalSyncFromRemoteMixin on OfflineFirstRepository {
  @override
  Future<List<_Model>> get<_Model extends OfflineFirstModel>({
    bool alwaysHydrate = false,
    bool hydrateUnexisting = true,

    /// When [forceLocalSyncFromRemote] is `true`, local instances that do not exist in the [remoteProvider]
    /// are destroyed. Further, when `true`, all values from other parameters except [query] are ignored.
    bool forceLocalSyncFromRemote = false,
    Query query,
    bool requireRemote = false,
    bool seedOnly = false,
  }) async {
    if (!forceLocalSyncFromRemote) {
      return await super.get<_Model>(
        alwaysHydrate: alwaysHydrate,
        hydrateUnexisting: hydrateUnexisting,
        query: query,
        requireRemote: requireRemote,
        seedOnly: seedOnly,
      );
    }

    return await destructiveLocalSyncFromRemote<_Model>(query: query);
  }

  /// When invoked, local instances that exist in [sqliteProvider] and [memoryCacheProvider] but
  /// do not exist in the [remoteProvider] are destroyed. The data from the [remoteProvider]
  /// should not be paginated and must be complete from a single request.
  Future<List<_Model>> destructiveLocalSyncFromRemote<_Model extends OfflineFirstModel>(
      {Query query}) async {
    query = (query ?? Query()).copyWith(action: QueryAction.get);
    logger.finest('#get: $_Model $query');

    final remoteResults = await remoteProvider.get<_Model>(query: query, repository: this);
    final localResults = await sqliteProvider.get<_Model>(query: query, repository: this);
    final toDelete = localResults.where((r) => !remoteResults.contains(r));

    for (final deletableModel in toDelete) {
      await sqliteProvider.delete(deletableModel);
      memoryCacheProvider.delete(deletableModel);
    }

    return await storeRemoteResults<_Model>(remoteResults);
  }
}
