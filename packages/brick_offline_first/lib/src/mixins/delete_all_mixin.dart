import 'package:brick_offline_first/offline_first.dart';

/// Adds functions [deleteAll] and [deleteAllExcept]
mixin DeleteAllMixin on OfflineFirstRepository {
  /// Delete every instance that matches [query] in all providers. Return value reflects if
  /// the operation completed without any failures.
  Future<bool> deleteAll<_Model extends OfflineFirstModel>({Query query}) async {
    final modelsToDelete = await get<_Model>(query: query);
    var allDeletesSuccessful = true;
    for (final model in modelsToDelete) {
      final didDelete = await delete<_Model>(model, query: query);
      if (!didDelete) allDeletesSuccessful = false;
    }

    return allDeletesSuccessful;
  }

  /// The convenient inverse of [deleteAll]. [query] defines the instances that **should not**
  /// be deleted. Return value reflects if the operation completed without any failures.
  Future<bool> deleteAllExcept<_Model extends OfflineFirstModel>({Query query}) async {
    final allModels = await get<_Model>();
    final modelsToKeep = await get<_Model>(query: query);
    final modelsToDelete = allModels.where((m) => !modelsToKeep.contains(m));

    var allDeletesSuccessful = true;
    for (final model in modelsToDelete) {
      final didDelete = await delete<_Model>(model, query: query);
      if (!didDelete) allDeletesSuccessful = false;
    }

    return allDeletesSuccessful;
  }
}
