# Data

Brick's architecture encourages using data through a single access point: the repository.

<img src="https://user-images.githubusercontent.com/865897/72239135-d4369400-3594-11ea-9a3f-49f8cdc9328a.jpg" width="180" height="490" alt="Data flow with a single provider" />

A repository _may_ implement multiple providers, but after instantiation the end application is only aware of the repository. The stream of data follows one course through each provider:

![Data flow with many providers](https://user-images.githubusercontent.com/865897/72480257-aecfa300-37ab-11ea-8cec-a1356854e744.jpg)

The repository is aware of provider(s), the provider(s) are aware of the adapters, the adapters are aware of models, and the models are aware of only themselves. From the reverse, models are unaware, adapters are unaware of providers and providers are unaware of repositories.

![Awareness](https://user-images.githubusercontent.com/865897/72176174-b26dbf00-3392-11ea-9d61-c2bd48e92345.jpg)

Because models are atomic and unaware, they don't rely on (de)serializing functions (unlike with [JSON serializable](https://github.com/dart-lang/json_serializable/blob/master/example/lib/example.dart#L29-L31)). Brick reduces the concerns of the end-implementation by hiding (de)serializing and fetching logic into adapters, which translate raw data between providers:

![Adapters](https://user-images.githubusercontent.com/865897/72480274-c3ac3680-37ab-11ea-899a-d5d5aa880c78.jpg)

## FAQ

### Do I have to get rid of BLoC or Scoped Model or Redux in my app to use Brick?

Nope. Those are _state_ managers. As a _store_ manager, Brick tracks and delivers persistent data across many sources, but it does not care about how you render that data. In fact, in its first app, Brick was integrated with BLoCs - the BLoC requested the data, Brick discovered the data, delivered the data back to the BLoC, and the BLoC delivered the data to the UI component for rendering.

As Repositories can output streams in `#getBatched`, a state manager could be easily bypassed. However, after trial and error, the Brick team determined the maintainence benefits of separating presentation and logic outweighed forgoing a state manager.
