import 'package:brick_core/core.dart';
import 'package:brick_offline_first/offline_first.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_sqlite/sqlite.dart';
import 'package:brick_sqlite_abstract/db.dart';

class TestProvider extends Provider<TestModel> {
  @override
  final TestModelDictionary modelDictionary;

  TestProvider(this.modelDictionary);

  @override
  bool delete<T extends TestModel>(T instance,
          {Query? query, ModelRepository<TestModel>? repository}) =>
      true;

  @override
  Future<List<T>> get<T extends TestModel>(
      {Query? query, ModelRepository<TestModel>? repository}) async {
    final adapter = modelDictionary.adapterFor[T]!;
    final data = [
      {'name': 'SqliteName'}
    ];
    return data
        .map((e) => adapter.fromTest(e, provider: this, repository: repository))
        .toList()
        .cast<T>();
  }

  @override
  Future<T> upsert<T extends TestModel>(T instance,
          {Query? query, ModelRepository<TestModel>? repository}) async =>
      instance;
}

/// Constructors that convert app models to and from REST
abstract class TestAdapter<_Model extends TestModel> implements Adapter<_Model> {
  Future<_Model> fromTest(
    Map<String, dynamic> input, {
    required TestProvider provider,
    ModelRepository<TestModel>? repository,
  });
  Future<Map<String, dynamic>> toTest(
    _Model input, {
    required TestProvider provider,
    ModelRepository<TestModel>? repository,
  });
}

/// Associates app models with their [TestAdapter]
class TestModelDictionary extends ModelDictionary<TestModel, TestAdapter<TestModel>> {
  const TestModelDictionary(Map<Type, TestAdapter<TestModel>> mappings) : super(mappings);
}

/// Models accessible to the [TestProvider]
abstract class TestModel implements Model {}

abstract class OfflineFirstWithTestModel extends OfflineFirstModel with TestModel {}

abstract class OfflineFirstWithTestAdapter<_Model extends OfflineFirstWithTestModel>
    extends OfflineFirstAdapter<_Model> with TestAdapter<_Model> {
  OfflineFirstWithTestAdapter();
}

abstract class OfflineFirstWithTestRepository
    extends OfflineFirstRepository<OfflineFirstWithTestModel> {
  OfflineFirstWithTestRepository({
    required TestProvider testProvider,
    required SqliteProvider sqliteProvider,
    required MemoryCacheProvider cacheProvider,
    required Set<Migration> migrations,
  }) : super(
          remoteProvider: testProvider,
          sqliteProvider: sqliteProvider,
          memoryCacheProvider: cacheProvider,
          migrations: migrations,
        );
}
