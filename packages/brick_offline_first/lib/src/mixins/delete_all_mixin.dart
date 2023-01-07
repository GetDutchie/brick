import 'package:brick_core/query.dart';
import 'package:brick_offline_first/src/models/offline_first_model.dart';
import 'package:brick_offline_first/src/offline_first_repository.dart';

/// Adds functions [deleteAll] and [deleteAllExcept]
mixin DeleteAllMixin<T extends OfflineFirstModel> on OfflineFirstRepository<T> {
  /// Delete every instance that matches [query] in all providers. Return value reflects if
  /// the operation completed without any failures.
  Future<bool> deleteAll<_Model extends T>({Query? query}) async {
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
  ///
  /// It is **strongly recommended** to use Equatable or to override the `==` operator in
  /// your app's models when incorporating this method. A delta between models to keep and
  /// models to remove is computed with `==`.
  Future<bool> deleteAllExcept<_Model extends T>({required Query query}) async {
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
