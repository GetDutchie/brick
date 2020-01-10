# Brick Core

Interfaces and shared helpers for implementing models, adapters, providers, and repositories in [Brick](../../).

## Principles

Brick's architecture encourages using data through a single access point: the repository.

![Data flow with a single provider](https://user-images.githubusercontent.com/865897/72176093-88b49800-3392-11ea-952b-9209f083f93d.jpg)

A repository _may_ implement multiple providers, but after instantiation the end application is only aware of the repository. The stream of data follows one course through each provider:

![Data flow with many providers](https://user-images.githubusercontent.com/865897/72176037-691d6f80-3392-11ea-9585-56ec2b363148.jpg)

The repository is aware of provider(s), the provider(s) are aware of the adapters, the adapters are aware of models, and the models are aware of only themselves. From the reverse, models are unaware, adapters are unaware of providers and providers are unaware of repositories.

![Awareness](https://user-images.githubusercontent.com/865897/72176174-b26dbf00-3392-11ea-9d61-c2bd48e92345.jpg)

Because models are atomic and unaware, they don't rely on (de)serializing functions (unlike with [JSON serializable](https://github.com/dart-lang/json_serializable/blob/master/example/lib/example.dart#L29-L31)). Brick reduces the concerns of the end-implementation by hiding (de)serializing and fetching logic into adapters, which translate raw data between providers:

![Adapters](https://user-images.githubusercontent.com/865897/72175940-370c0d80-3392-11ea-9f76-824227c25247.jpg)
