import 'package:brick_core/src/model_dictionary.dart';
import 'package:brick_core/src/model_repository.dart';
import 'package:brick_core/src/query/query.dart';
import 'package:brick_core/src/model.dart';

/// A [Provider] fetches raw data and creates [Model]s. An app can have many [Provider]s.
abstract class Provider<TModel extends Model> {
  /// The translation between [Adapter]s and [Model]s
  ModelDictionary get modelDictionary;

  const Provider();

  /// Remove a model instance
  // ignore: always_declare_return_types
  delete<T extends TModel>(T instance, {Query? query, ModelRepository<TModel>? repository});

  /// Whether a model instance is present. `null` is returned when existence is unknown.
  /// The model instance is not hydrated in the function output; a `bool` variant
  /// (e.g. `List<bool>`, `Map<TModel, bool>`) should be returned.
  // ignore: always_declare_return_types
  exists<T extends TModel>({Query? query, ModelRepository<TModel>? repository}) => null;

  /// Query for raw data and construct it with an [Adapter]
  // ignore: always_declare_return_types
  get<T extends TModel>({Query? query, ModelRepository<TModel>? repository});

  /// Insert or update a model instance
  // ignore: always_declare_return_types
  upsert<T extends TModel>(T instance, {Query? query, ModelRepository<TModel>? repository});
}
