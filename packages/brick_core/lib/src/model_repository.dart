import 'dart:async';

import 'query.dart';
import 'model.dart';
import 'provider.dart';

/// A Repository is the top-level means of relaying data between [Model]s and [Provider]s.
/// A conventional implementation would adhere to the singleton pattern.
///
/// It should handle the app's caching strategy between [Provider]s. For example, if an app has
/// an offline-first caching strategy, the Repository first fetches from a `SqliteProvider`
/// and then a `RestProvider` before returning one result. An app should have one [Repository] for
/// one data flow (similar to having one Redux store as the source of truth).
///
/// `implement`ing this class is not necessary. It's supplied as a standardized, opinionated way to
/// structure your `Store`.
abstract class ModelRepository<_ManagedModel extends Model> {
  const ModelRepository();

  /// Delete a model from all [Provider]s.
  ///
  /// Optionally, the repository can
  /// be passed to the same provider method with a named argument (`repository: this`) to use in
  /// the [Adapter].
  delete<_Model extends _ManagedModel>(_Model instance, {Query query});

  /// Query for raw data from all [Provider]s.
  ///
  /// Optionally, the repository can
  /// be passed to the same provider method with a named argument (`repository: this`) to use in
  /// the [Adapter].
  get<_Model extends _ManagedModel>({Query query});

  /// Insert or update a model in all [Provider]s
  ///
  /// Optionally, the repository can
  /// be passed to the same provider method with a named argument (`repository: this`) to use in
  /// the [Adapter].
  upsert<_Model extends _ManagedModel>(_Model model, {Query query});
}

/// Helper for mono provider systems
abstract class SingleProviderRepository<_Model extends Model> implements ModelRepository<_Model> {
  /// The only provider for the store
  final Provider<_Model> provider;

  const SingleProviderRepository(this.provider);

  /// Remove models from providers
  FutureOr<bool> delete<T extends _Model>(T instance, {Query query}) =>
      provider.delete<T>(instance, query: query, repository: this);

  /// Query provider for raw data and convert to an app model
  FutureOr<List<T>> get<T extends _Model>({Query query}) =>
      provider.get<T>(query: query, repository: this);

  /// Query provider for raw data and convert to an app model
  FutureOr<T> upsert<T extends _Model>(T instance, {Query query}) =>
      provider.upsert<T>(instance, query: query, repository: this);
}
