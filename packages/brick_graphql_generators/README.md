![brick_graphql_generators workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_graphql_generators.yaml/badge.svg)

# Brick GraphQL Build

Code generator that provides (de)serializing functions for Brick adapters using GraphqlProvider. This package **does not** produce code. It can be imported into other Brick build domains.

This package should not be imported into an end application as it does not generate code.

## Usage

Apply the `GraphQLSerdes` in your own `AnnotationSuperGenerator`:

```dart
import 'package:brick_graphql_generators/graphql_serdes.dart';

class MyDomainGenerator extends AnnotationSuperGenerator<ConnectMyDomainWithGraphQL> {
  final String superAdapterName;
  final String repositoryName;

  const OfflineFirstGenerator({
    this.superAdapterName = 'MyDomain',
    this.repositoryName = 'MyDomainWithGraphQL',
  });

  /// Given an [element] and an [annotation], scaffold generators
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final graphql = GraphQLSerdes(element, annotation, repositoryName: repositoryName);
    final otherProvider = OtherProviderSerdes(element, annotation, repositoryName: repositoryName);
    final generators = <SerdesGenerator>[];
    generators.addAll(graphql.generators);
    generators.addAll(otherProvider.generators);
    return generators;
  }
}
```
