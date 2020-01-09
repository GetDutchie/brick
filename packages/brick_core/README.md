# Brick Core

Interfaces and shared helpers for implementing classes.

## Principles

Brick's architecture encourages using data through a single access point. Therefore, the stream of data follows one course through each provider. The repository is aware of provider(s), the provider(s) are aware of the adapters, the adapters are aware of models, and the models are aware of only themselves. From the reverse, models are unaware, adapters are unaware of providers and providers are unaware of repositories.

Because models are atomic and unaware, they don't rely on (de)serializing functions (unlike with [JSON serializable](https://github.com/dart-lang/json_serializable/blob/master/example/lib/example.dart#L29-L31)). Brick reduces the concerns of the end-implementation by hiding (de)serializing and fetching logic.
