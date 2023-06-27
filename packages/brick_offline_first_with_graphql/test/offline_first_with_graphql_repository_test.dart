import 'package:brick_core/core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '__helpers__.dart';
import 'test_domain/__mocks__.dart';

void main() {
  sqfliteFfiInit();

  group('OfflineFirstWithGraphqlRepository', () {
    test('instantiates', () {
      final repository = TestRepository.configure(link: stubGraphqlLink({}));
      expect(repository.remoteProvider.link.runtimeType.toString(), '_LinkChain');
    });

    group('#get', () {
      test('simple', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({'name': 'SqliteName'}));
        await repository.initialize();
        await repository.migrate();

        final results = await repository.get<Mounty>();
        expect(results, hasLength(1));
        expect(results.first.name, 'SqliteName');
      });

      test('one-to-many, many-to-many', () async {
        final mounties = [Mounty(name: 'Thomas'), Mounty(name: 'Guy')];
        final horse = Horse(name: 'Not Thomas', mounties: mounties);
        final repository = TestRepository.configure(link: stubGraphqlLink({'name': 'SqliteName'}));
        await repository.initialize();
        await repository.migrate();

        await repository.sqliteProvider.upsert<Horse>(horse);
        final results = await repository.sqliteProvider.get<Horse>(repository: repository);

        expect(results.first.mounties, hasLength(2));
        expect(results.first.mounties.first.primaryKey, greaterThan(0));
        expect(results.first.mounties.last.primaryKey, greaterThan(0));
        final findByName = await repository.sqliteProvider.get<Horse>(
          repository: repository,
          query: Query(
            where: [
              const Where('mounties').isExactly(Where.exact('name', mounties.first.name)),
            ],
          ),
        );

        expect(findByName.first.name, horse.name);
      });
    });

    test('#getBatched', () async {
      final repository = TestRepository.configure(link: stubGraphqlLink({'name': 'SqliteName'}));
      await repository.initialize();
      await repository.migrate();

      final results = await repository.getBatched<Mounty>();
      expect(results.first, isA<Mounty>());
      expect(results.first.name, 'SqliteName');
    });
  });
}
