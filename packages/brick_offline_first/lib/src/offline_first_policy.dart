/// Behaviors for how the repository should handle delete requests
enum OfflineFirstDeletePolicy {
  /// Delete local results before waiting for the remote provider to respond
  optimisticLocal,

  /// Delete local results after remote responds; local results are not deleted if remote responds with any exception
  requireRemote,
}

/// Data will **always** be returned from local providers and never directly
/// from a remote provider(s)
enum OfflineFirstGetPolicy {
  /// Ensures data is fetched from the remote provider(s) at each invocation.
  /// This hydration is unawaited and is not guaranteed to complete before results are returned.
  /// This can be expensive to perform for some queries; see [awaitRemoteWhenNoneExist]
  /// for a more performant option or [awaitRemote] to await the hydration before returning results.
  alwaysHydrate,

  /// Ensures results must be updated from the remote proivder(s) before returning if the app is online.
  /// An empty array will be returned if the app is offline.
  awaitRemote,

  /// Retrieves from the remote provider(s) if the query returns no results from the local provider(s).
  awaitRemoteWhenNoneExist,

  /// Do not request from the remote provider(s)
  localOnly,
}

/// Behaviors for how the repository should handle upsert requests
enum OfflineFirstUpsertPolicy {
  /// Save results to local before waiting for the remote provider to respond
  optimisticLocal,

  /// Save results to local after remote responds;
  /// local results are not saved if remote responds with any exception
  requireRemote,
}
