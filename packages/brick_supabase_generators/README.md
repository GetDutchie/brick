![brick_supabase_generators workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_supabase_generators.yaml/badge.svg)

# Brick Supabase Generators

Code generator that provides (de)serializing functions for Brick adapters using SupabaseProvider. This package **does not** produce code. It can be imported into other Brick build domains.

This package should not be imported into an end application as it does not generate code.

## Usage

Apply the `SupabaseSerdes` in your own `AnnotationSuperGenerator`:

```dart
import 'package:brick_supabase_generators/supabase_serdes.dart';

class MyDomainGenerator extends AnnotationSuperGenerator<ConnectMyDomainWithSupabase> {
  final String superAdapterName;
  final String repositoryName;

  const OfflineFirstGenerator({
    this.superAdapterName = 'MyDomain',
    this.repositoryName = 'MyDomainWithSupabase',
  });

  /// Given an [element] and an [annotation], scaffold generators
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final supabase = SupabaseSerdes(element, annotation, repositoryName: repositoryName);
    final otherProvider = OtherProviderSerdes(element, annotation, repositoryName: repositoryName);
    final generators = <SerdesGenerator>[];
    generators.addAll(supabase.generators);
    generators.addAll(otherProvider.generators);
    return generators;
  }
}
```
