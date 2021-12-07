![brick_sqlite_generators workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_sqlite_generators.yaml/badge.svg)

# Brick Sqlite Build

Code generator that provides (de)serializing functions for Brick adapters using SqliteProvider. This package **does not** produce code. It can be imported into other Brick build domains.

This package should not be imported into an end application as it does not generate code.

## Usage

Apply the `SqliteSerdes` in your own `AnnotationSuperGenerator`:

```dart
import 'package:brick_rest_generators/rest_serdes.dart';

class MyDomainGenerator extends AnnotationSuperGenerator<ConnectOfflineFirst> {
  final String superAdapterName;
  final String repositoryName;

  const OfflineFirstGenerator({
    this.superAdapterName = 'OfflineFirst',
    this.repositoryName = 'OfflineFirst',
  });

  /// Given an [element] and an [annotation], scaffold generators
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final sqlite = SqliteSerdes(element, annotation, repositoryName: repositoryName);
    final otherProvider = OtherProviderSerdes(element, annotation, repositoryName: repositoryName);
    final generators = <SerdesGenerator>[];
    generators.addAll(sqlite.generators);
    generators.addAll(otherProvider.generators);
    return generators;
  }
}
```
