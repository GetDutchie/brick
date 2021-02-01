# Testing

SQLite providers should use sqlite_ffi as described in [multiplatform support](sqlite.md#multiplatform-support):

```dart
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  ft.TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final provider = SqliteProvider(
    inMemoryDatabasePath,
    databaseFactory: databaseFactoryFfi,
    modelDictionary: dictionary,
  );

  setUpAll(() async {
    await provider.migrate(myMigrations);
    // upsert any expected data
    await provider.upsert<DemoModel>(DemoModel('Guy'));
  });
}
```
