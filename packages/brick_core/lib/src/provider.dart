import 'model_dictionary.dart';
import 'model_repository.dart';
import 'query.dart';
import 'model.dart';

/// A [Provider] fetches raw data and creates [Model]s. An app can have many [Provider]s.
abstract class Provider<_Model extends Model> {
  /// The translation between [Adapter]s and [Model]s
  ModelDictionary get modelDictionary;

  const Provider();

  /// Remove a model instance
  delete<T extends _Model>(T instance, {Query query, ModelRepository<_Model> repository});

  /// Query for raw data and construct it with an [Adapter]
  get<T extends _Model>({Query query, ModelRepository<_Model> repository});

  /// Insert or update a model instance
  upsert<T extends _Model>(T instance, {Query query, ModelRepository<_Model> repository});
}
