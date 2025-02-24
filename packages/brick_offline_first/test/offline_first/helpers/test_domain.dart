// ignore_for_file: prefer_mixin

import 'dart:io';

import 'package:brick_core/core.dart';
import 'package:brick_offline_first/src/models/offline_first_model.dart';
import 'package:brick_offline_first/src/offline_first_adapter.dart';
import 'package:brick_offline_first/src/offline_first_repository.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';

import '__mocks__.dart';

class TestProvider extends Provider<TestModel> {
  final methodsCalled = <String>[];

  @override
  final TestModelDictionary modelDictionary;

  TestProvider(this.modelDictionary);

  @override
  bool delete<T extends TestModel>(
    T instance, {
    Query? query,
    ModelRepository<TestModel>? repository,
  }) {
    methodsCalled.add('delete');
    if (TestRepository.throwOnNextRemoteMutation) throw const SocketException('Remote failed');
    return true;
  }

  @override
  Future<List<T>> get<T extends TestModel>({
    Query? query,
    ModelRepository<TestModel>? repository,
  }) async {
    methodsCalled.add('get');
    final adapter = modelDictionary.adapterFor[T]!;
    final data = [
      {'name': 'SqliteName'},
    ];
    final results = data
        .map((e) => adapter.fromTest(e, provider: this, repository: repository))
        .toList()
        .cast<Future<T>>();
    return await Future.wait<T>(results);
  }

  @override
  Future<T> upsert<T extends TestModel>(
    T instance, {
    Query? query,
    ModelRepository<TestModel>? repository,
  }) {
    methodsCalled.add('upsert');
    if (TestRepository.throwOnNextRemoteMutation) throw const SocketException('Remote failed');
    return Future<T>.value(instance);
  }
}

/// Constructors that convert app models to and from REST
abstract mixin class TestAdapter<TModel extends TestModel> implements Adapter<TModel> {
  Future<TModel> fromTest(
    Map<String, dynamic> input, {
    required TestProvider provider,
    ModelRepository<TestModel>? repository,
  });
  Future<Map<String, dynamic>> toTest(
    TModel input, {
    required TestProvider provider,
    ModelRepository<TestModel>? repository,
  });
}

/// Associates app models with their [TestAdapter]
class TestModelDictionary extends ModelDictionary<TestModel, TestAdapter<TestModel>> {
  // ignore: use_super_parameters
  const TestModelDictionary(Map<Type, TestAdapter<TestModel>> mappings) : super(mappings);
}

/// Models accessible to the [TestProvider]
abstract mixin class TestModel implements Model {}

abstract class OfflineFirstWithTestModel extends OfflineFirstModel with TestModel {}

abstract class OfflineFirstWithTestAdapter<TModel extends OfflineFirstWithTestModel>
    extends OfflineFirstAdapter<TModel> with TestAdapter<TModel> {
  OfflineFirstWithTestAdapter();
}

abstract class OfflineFirstWithTestRepository
    extends OfflineFirstRepository<OfflineFirstWithTestModel> {
  OfflineFirstWithTestRepository({
    required TestProvider testProvider,
    required super.sqliteProvider,
    required MemoryCacheProvider cacheProvider,
    required super.migrations,
  }) : super(
          remoteProvider: testProvider,
          memoryCacheProvider: cacheProvider,
        );
}
