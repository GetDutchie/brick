# Quick Start

1. Add the packages:
    ```yaml
    dependencies:
      brick_offline_first: any
    dev_dependencies:
      brick_offline_first_with_rest_build:
        git:
          url: https://github.com/greenbits/brick.git
          path: packages/brick_offline_first_with_rest_build
      build_runner: any
    ```

1. Configure your app directory structure to match Brick's expectations:
    ```bash
    mkdir -p lib/app/adapters lib/app/db lib/app/models;
    ```
1. Add [models](data/models.md) that contain your app logic. Models **must be** saved in `lib/app/models/<class_as_snake_name>.dart`.
1. Run `flutter pub run build_runner run` to generate your models (or `pub run build_runner run` if you're not using Flutter).
1. Extend [an existing repository](data/repositories.md) or create your own:
    ```dart
    // lib/app/repository.dart
    import 'package:brick_offline_first/offline_first_with_rest.dart';
    import 'package:audio_journal/app/brick.g.dart';

    class Repository extends OfflineFirstWithRestRepository {
      Repository()
          : super(
              restProvider: RestProvider(
                'http://localhost:3000',
                modelDictionary: restModelDictionary,
              ),
              sqliteProvider: SqliteProvider(
                _DB_NAME,
                modelDictionary: sqliteModelDictionary,
              ),
            );
    }
    ```
1. Profit.

## Recommended but Optional

**Ignore generated files in `.gitignore`**. It is recommended to **not** commit files appended with `.g.dart` to version control. Instead, these files should be built on every `pull` as well as on every build in a CI/CD pipeline. This ensures your code is generated with the most recent version of Brick and remains untouchable by contributors.

```
*.g.dart
# alternately, uncomment the lines below to only target brick files
# app/adapters/*.dart
# app/db/*.g.dart
# app/brick.g.dart
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
