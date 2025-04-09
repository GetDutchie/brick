// ignore_for_file: type_annotate_public_apis, always_declare_return_types

import 'dart:async';

import 'package:brick_core/src/model.dart';
import 'package:brick_core/src/provider.dart';
import 'package:brick_core/src/query/query.dart';

/// A [ModelRepository] is the top-level means of relaying data between [Model]s and [Provider]s.
/// A conventional implementation would adhere to the singleton pattern.
///
/// It should handle the app's caching strategy between [Provider]s. For example, if an app has
/// an offline-first caching strategy, the [ModelRepository] first fetches from a `SqliteProvider`
/// and then a `RestProvider` before returning one result. An app should have one `Repository` for
/// one data flow (similar to having one Redux store as the source of truth).
///
/// `implement`ing this class is not necessary.
abstract class ModelRepository<ManagedModel extends Model> {
  /// A [ModelRepository] is the top-level means of relaying data between [Model]s and [Provider]s.
  /// A conventional implementation would adhere to the singleton pattern.
  ///
  /// It should handle the app's caching strategy between [Provider]s. For example, if an app has
  /// an offline-first caching strategy, the [ModelRepository] first fetches from a `SqliteProvider`
  /// and then a `RestProvider` before returning one result. An app should have one `Repository` for
  /// one data flow (similar to having one Redux store as the source of truth).
  ///
  /// `implement`ing this class is not necessary.
  const ModelRepository();

  /// Delete a model from all [Provider]s.
  ///
  /// Optionally, the repository can be passed to the same provider method
  /// with a named argument (`repository: this`) to use in the `Adapter`.
  delete<TModel extends ManagedModel>(TModel instance, {Query query});

  /// Query for raw data from all [Provider]s.
  ///
  /// Optionally, the repository can be passed to the same provider method
  /// with a named argument (`repository: this`) to use in the `Adapter`.
  get<TModel extends ManagedModel>({Query query});

  /// Perform required setup work. For example, migrating a database, starting a queue,
  /// or authenticating with a [Provider]'s service.
  // ignore: avoid_returning_null_for_void
  Future<void> initialize() async => null;

  /// Insert or update a model in all [Provider]s
  ///
  /// Optionally, the repository can be passed to the same provider method
  /// with a named argument (`repository: this`) to use in the `Adapter`.
  upsert<TModel extends ManagedModel>(TModel model, {Query query});
}

/// Helper for mono provider systems. This is generally used to simplify code for package examples.
/// It is discouraged to extend this class for practical applications.
///
/// If a single provider is necessary, access that provider directly (i.e. `RestProvider()`) or
/// the backing client (e.g. `http.Client`, sqflite's `databaseFactory`) directly until your
/// implementation requires multi-provider features.
abstract class SingleProviderRepository<TModel extends Model> implements ModelRepository<TModel> {
  /// The only provider for the repository
  final Provider<TModel> provider;

  /// Helper for mono provider systems
  const SingleProviderRepository(this.provider);

  /// Remove models from providers
  @override
  FutureOr<bool> delete<T extends TModel>(T instance, {Query? query}) =>
      provider.delete<T>(instance, query: query, repository: this);

  /// Query provider for raw data and convert to an app model
  @override
  FutureOr<List<T>> get<T extends TModel>({Query? query}) =>
      provider.get<T>(query: query, repository: this);

  @override
  Future<void> initialize() async {}

  /// Query provider for raw data and convert to an app model
  @override
  FutureOr<T> upsert<T extends TModel>(T instance, {Query? query}) =>
      provider.upsert<T>(instance, query: query, repository: this);
}
