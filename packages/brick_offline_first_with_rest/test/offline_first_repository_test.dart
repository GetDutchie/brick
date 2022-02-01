import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/__mocks__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('OfflineFirstRepository', () {
    const baseUrl = 'http://0.0.0.0:3000';

    setUpAll(() async {
      TestRepository.configure(
        sqliteDictionary: sqliteModelDictionary,
      );

      await TestRepository().initialize();
    });

    test('instantiates', () {
      // isA matcher didn't work
      expect(
          TestRepository().remoteProvider.client.runtimeType.toString(), 'RestOfflineQueueClient');
    });
  });
}
