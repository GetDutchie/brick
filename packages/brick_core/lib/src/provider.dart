// ignore_for_file: type_annotate_public_apis, always_declare_return_types

import 'package:brick_core/src/adapter.dart';
import 'package:brick_core/src/model.dart';
import 'package:brick_core/src/model_dictionary.dart';
import 'package:brick_core/src/model_repository.dart';
import 'package:brick_core/src/query/query.dart';

/// A [Provider] fetches raw data and creates [Model]s. An app can have many [Provider]s.
abstract class Provider<TModel extends Model> {
  /// The translation between [Adapter]s and [Model]s
  ModelDictionary get modelDictionary;

  /// A [Provider] fetches raw data and creates [Model]s. An app can have many [Provider]s.
  const Provider();

  /// Remove a model instance
  delete<T extends TModel>(T instance, {Query? query, ModelRepository<TModel>? repository});

  /// Whether a model instance is present. `null` is returned when existence is unknown.
  /// The model instance is not hydrated in the function output; a `bool` variant
  /// (e.g. `List<bool>`, `Map<TModel, bool>`) should be returned.
  exists<T extends TModel>({Query? query, ModelRepository<TModel>? repository}) => null;

  /// Query for raw data and construct it with an [Adapter]
  get<T extends TModel>({Query? query, ModelRepository<TModel>? repository});

  /// Insert or update a model instance
  upsert<T extends TModel>(T instance, {Query? query, ModelRepository<TModel>? repository});
}
