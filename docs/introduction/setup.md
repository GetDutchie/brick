# Quick Start

1. Add the packages:

   ```yaml
   dependencies:
     # or brick_offline_first_with_graphql: any
     # or brick_offline_first_with_supabase: any
     brick_offline_first_with_rest: any
   dev_dependencies:
     # or brick_offline_first_with_graphql_build: any
     # or brick_offline_first_with_supabase_build: any
     brick_offline_first_with_rest_build: any
     build_runner: any
   ```

1. Configure your app directory structure to match Brick's expectations:
   ```bash
   mkdir -p lib/brick/adapters lib/brick/db;
   ```
1. Add [models](../data/models) that contain your app logic. Models **must be** saved with the `.model.dart` suffix (i.e. `lib/brick/models/person.model.dart`).
1. Run `flutter pub run build_runner build` to generate your models (or `pub run build_runner build` if you're not using Flutter) and [sometimes migrations](../sqlite.md#intelligent-migrations). Rerun after every new model change or `flutter pub run build_runner watch` for automatic generations.
1. Extend [an existing repository](../data/repositories.md) or create your own:

   ```dart
   // lib/brick/repository.dart
   import 'package:brick_offline_first/brick_offline_first_with_rest.dart';
   import 'package:my_app/brick/brick.g.dart';
   export 'package:brick_offline_first/brick_offline_first_with_rest.dart' show And, Or, Query, QueryAction, Where, WherePhrase;

   class Repository extends OfflineFirstWithRestRepository {
     Repository()
         : super(
             migrations: migrations,
             restProvider: RestProvider(
               'http://0.0.0.0:3000',
               modelDictionary: restModelDictionary,
             ),
             sqliteProvider: SqliteProvider(
               _DB_NAME,
               modelDictionary: sqliteModelDictionary,
             ),
             offlineQueueManager: RestRequestSqliteCacheManager(
               'brick_offline_queue.sqlite',
               databaseFactory: databaseFactory,
             ),
           );
   }
   ```

1. Profit.

!> **Apps that distribute to Windows** should be sure to specify an absolute path to their SQLite instance (see [#378](https://github.com/GetDutchie/brick/pull/378/files) for discussion):

```dart
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite_common/sqflite.dart';
...
final directory = Platform.isWindows ? (await getApplicationSupportDirectory()).path : await getDatabasesPath();
...
sqliteProvider: SqliteProvider(
  join(directory, _DB_NAME),
  modelDictionary: sqliteModelDictionary,
),
offlineQueueManager: RestRequestSqliteCacheManager(
  join(directory, 'brick_offline_queue.sqlite'),
  databaseFactory: databaseFactory,
),
```

## Recommended but Optional

**Ignore generated files in `.gitignore`**. It is recommended to **not** commit files appended with `.g.dart` to version control. Instead, these files should be built on every `pull` as well as on every build in a CI/CD pipeline. This ensures your code is generated with the most recent version of Brick and remains untouchable by contributors.

```
*.g.dart
# alternately, uncomment the lines below to only target brick files
# brick/adapters/*.dart
# brick/db/*.g.dart
# brick/brick.g.dart
```

**Generate files on every significant change**. While not required, this is recommend especially for teams and open source projects. It's required when `*.g.dart` files are ignored. To automate the generation without using `build_runner watch`, the following can be added to `.git/hooks/post-checkout`:

```bash
# .git/post-checkout
#!/bin/sh

cd `dirname "$0"`
cd ../../
flutter pub get
flutter pub run build_runner build
```

Ensure that the `post-checkout` file is executable:

```bash
chmod 755 .git/hooks/post-checkout
```
