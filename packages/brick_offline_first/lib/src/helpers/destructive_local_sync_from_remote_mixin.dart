import 'package:brick_offline_first/offline_first.dart';

/// Provides an extended `get` method to support
mixin DestructiveLocalSyncFromRemoteMixin on OfflineFirstRepository {
  @override
  Future<List<_Model>> get<_Model extends OfflineFirstModel>({
    bool alwaysHydrate = false,
    bool hydrateUnexisting = true,

    /// When [forceLocalSyncFromRemote] is `true`, `requireRemote`, `alwaysHydrate`, and `hydrateUnexisting` will be `true`.
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
