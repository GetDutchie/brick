![brick_rest_generators workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_rest_generators.yaml/badge.svg)

# Brick Rest Build

Code generator that provides (de)serializing functions for Brick adapters using RestProvider. This package **does not** produce code. It can be imported into other Brick build domains.

This package should not be imported into an end application as it does not generate code.

## Usage

Apply the `RestSerdes` in your own `AnnotationSuperGenerator`:

```dart
import 'package:brick_rest_generators/rest_serdes.dart';

class MyDomainGenerator extends AnnotationSuperGenerator<ConnectMyDomainWithRest> {
  final String superAdapterName;
  final String repositoryName;

  const OfflineFirstGenerator({
    this.superAdapterName = 'MyDomain',
    this.repositoryName = 'MyDomainWithRest',
  });

  /// Given an [element] and an [annotation], scaffold generators
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final rest = RestSerdes(element, annotation, repositoryName: repositoryName);
    final otherProvider = OtherProviderSerdes(element, annotation, repositoryName: repositoryName);
    final generators = <SerdesGenerator>[];
    generators.addAll(rest.generators);
    generators.addAll(otherProvider.generators);
    return generators;
  }
}
```
