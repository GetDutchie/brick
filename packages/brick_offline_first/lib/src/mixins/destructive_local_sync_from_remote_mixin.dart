import 'package:brick_core/query.dart';
import 'package:brick_offline_first/src/models/offline_first_model.dart';
import 'package:brick_offline_first/src/offline_first_policy.dart';
import 'package:brick_offline_first/src/offline_first_repository.dart';

/// Provides an extended `get` method to support remote syncs that override local data.
/// For example, if two models exist in the `remoteProvider` but three exist in `sqliteProvider`
/// and `memoryCacheProvider`, the extra model is removed from the local providers when
/// `#get:forceLocalSyncFromRemote` is true or when [destructiveLocalSyncFromRemote] is invoked.
///
/// Using this mixin and its methods requires that the data from the [remoteProvider]
/// should not be paginated and complete from a single request.
mixin DestructiveLocalSyncFromRemoteMixin<T extends OfflineFirstModel>
    on OfflineFirstRepository<T> {
  /// When [forceLocalSyncFromRemote] is `true`, local instances that do not exist in the [remoteProvider]
  /// are destroyed. Further, when `true`, all values from other parameters except [query] are ignored.
  @override
  Future<List<TModel>> get<TModel extends T>({
    bool forceLocalSyncFromRemote = false,
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    Query? query,
    bool seedOnly = false,
  }) async {
    if (!forceLocalSyncFromRemote) {
      return await super.get<TModel>(
        query: query,
        policy: policy,
        seedOnly: seedOnly,
      );
    }

    return await destructiveLocalSyncFromRemote<TModel>(query: query);
  }

  /// When invoked, local instances that exist in [sqliteProvider] and [memoryCacheProvider] but
  /// do not exist in the [remoteProvider] are destroyed. The data from the [remoteProvider]
  /// should not be paginated and must be complete from a single request.
  Future<List<TModel>> destructiveLocalSyncFromRemote<TModel extends T>({Query? query}) async {
    query = (query ?? const Query()).copyWith(action: QueryAction.get);
    logger.finest('#get: $TModel $query');

    final remoteResults = await remoteProvider.get<TModel>(query: query, repository: this);
    final localResults = await sqliteProvider.get<TModel>(query: query, repository: this);
    final toDelete = localResults.where((r) => !remoteResults.contains(r));

    for (final deletableModel in toDelete) {
      await sqliteProvider.delete(deletableModel);
      memoryCacheProvider.delete(deletableModel);
    }

    return await storeRemoteResults<TModel>(remoteResults);
  }
}
