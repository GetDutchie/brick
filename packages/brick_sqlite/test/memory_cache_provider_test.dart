import 'package:brick_core/core.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/models/sqlite_model.dart';
import 'package:test/test.dart';

class Person extends SqliteModel {}

class PersonGroup extends SqliteModel {}

void main() {
  group('MemoryCacheProvider', () {
    late MemoryCacheProvider provider;

    setUp(() {
      provider = MemoryCacheProvider([Person]);
    });

    test('#managedModelTypes', () {
      expect(provider.managedModelTypes, [Person]);
    });

    test('#manages', () {
      expect(provider.manages(Person), isTrue);
      expect(provider.manages(PersonGroup), isFalse);
    });

    test('#canFind', () {
      final byPrimaryKey = Query.where(InsertTable.PRIMARY_KEY_FIELD, 1);

      expect(provider.manages(Person), isTrue);
      expect(provider.canFind<Person>(byPrimaryKey), isTrue);
      expect(provider.manages(PersonGroup), isFalse);
      expect(provider.canFind<PersonGroup>(), isFalse);
      expect(provider.canFind<PersonGroup>(byPrimaryKey), isFalse);
    });

    test('#delete', () {
      final instance = Person()..primaryKey = 1;
      provider.hydrate<Person>([instance]);
      expect(provider.managedObjects, isNotEmpty);
      expect(provider.managedObjects[Person], isNotEmpty);

      provider.delete<Person>(instance);
      expect(provider.managedObjects, isNotEmpty);
      expect(provider.managedObjects[Person], {});
    });

    group('#get', () {
      test('unmanaged types', () {
        expect(provider.get<PersonGroup>(), isNull);
      });

      test('.id queries', () {
        final instance = Person()..primaryKey = 1;
        provider.hydrate<Person>([instance]);
        final results = provider.get<Person>(
          query: const Query(
            where: [Where.exact(InsertTable.PRIMARY_KEY_FIELD, 1)],
            limit: 1,
          ),
        );
        expect(results, isNotEmpty);
        expect(results, contains(instance));
      });

      test('unlimited queries', () {
        final instance = Person()..primaryKey = 1;
        provider.hydrate<Person>([instance]);
        final results = provider.get<Person>();

        expect(results, isNull);
      });
    });

    test('#hydrate<Person>', () {
      expect(provider.managedObjects, isEmpty);

      final instance = Person()..primaryKey = 1;
      provider.hydrate<Person>([instance]);
      expect(provider.managedObjects, isNotEmpty);
      expect(provider.managedObjects[Person], isNotNull);
      expect(provider.managedObjects[Person]![1], isNotNull);

      // does not insert null ids
      final instanceWithoutId = Person();
      expect(instanceWithoutId.primaryKey, isNull);
      expect(provider.managedObjects[Person]!.values, hasLength(1));
      provider.hydrate<Person>([instanceWithoutId]);
      expect(provider.managedObjects[Person]!.values, hasLength(1));
    });

    test('#reset', () {
      final instance = Person()..primaryKey = 1;
      provider.hydrate<Person>([instance]);
      expect(provider.managedObjects[Person], isNotEmpty);
      provider.reset();
      expect(provider.managedObjects, isEmpty);
    });
  });
}
