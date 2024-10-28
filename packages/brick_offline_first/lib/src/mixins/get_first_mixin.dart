import 'package:brick_offline_first/brick_offline_first.dart';

/// A convenience mixin for single-instance get operations.
mixin GetFirstMixin<CModel extends OfflineFirstModel> on OfflineFirstRepository<CModel> {
  /// Retrieves the first instance of [TModel] with certainty that it exists.
  /// If no instances exist, a [StateError] is thrown from within Dart's core
  /// `Iterable#first` method. It is recommended to use [getFirstOrNull] instead.
  ///
  /// Automatically applies `'limit': 1` to the query's `providerArgs`
  Future<TModel> getFirst<TModel extends CModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    Query? query,
    bool seedOnly = false,
  }) async {
    final result = await super.get<TModel>(
      policy: policy,
      query: query?.copyWith(providerArgs: {'limit': 1}),
      seedOnly: seedOnly,
    );

    return result.first;
  }

  /// A safer version of [getFirst] that attempts to get the first instance of [TModel]
  /// according to the [query], but returns `null` if no instances exist.
  ///
  /// Automatically applies `'limit': 1` to the query's `providerArgs`
  Future<TModel?> getFirstOrNull<TModel extends CModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    Query? query,
    bool seedOnly = false,
  }) async {
    final result = await super.get<TModel>(
      policy: policy,
      query: query?.copyWith(providerArgs: {'limit': 1}),
      seedOnly: seedOnly,
    );

    if (result.isEmpty) return null;
    return result.first;
  }
}
