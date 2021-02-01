# Quick Start

End-implementation uses (e.g. a Flutter application) should `extend` an abstract repository and pass arguments to `super`. If custom methods need to be added, they can be written in the application-specific repository and not the abstract one. Application-specific `brick.g.dart` are also imported:

```dart
// app/repository.dart
import 'brick.g.dart' show migrations, restModelDictionary;
class MyRepository extends OfflineFirstRepository {
  MyRepository({
    String baseEndpoint,
  }) : super(
    migrations: migrations,
    restProvider: RestProvider(baseEndpoint, modelDictionary: restModelDictionary),
  );
}
```

## Learn

* Video: [Brick Architecture](https://www.youtube.com/watch?v=2noLcro9iIw). An explanation of Brick parlance with a supplemental analogy.
* Video: [Brick Basics](https://www.youtube.com/watch?v=jm5i7e_BQq0). An overview of essential Brick mechanics.
* Example: [Simple Associations using the OfflineFirstWithRest domain](https://github.com/greenbits/brick/blob/master/example)
* Tutorial: [Setting up a simple app with Brick](http://www.flutterbyexample.com/#/posts/2_adding_a_repository)

## Glossary

* **source** - external information warehouse that delivers unrefined data
* [**Provider**](data/providers.md) - fetches from and pushes to a `source`
* [**Repository**](data/repositories.md) - manages `Provider`(s) and determines which provider results to send
* **Adapter** - normalizes data input and output between `Provider`s
* [**Model**](data/models.md) - business logic unique to the app. Fetched by the `Repository`, and if merited by the `Repository` implementation, the `Provider`.
* **ModelDictionary** - guides a `Provider` to the `Model`'s `Adapter`. Unique per `Provider`.
* **field** - single, accessible property of a model. For example, `final String id`
* **deserialize** - convert raw data _from_ a provider
* **serialize** - convert a model instance _to_ raw data for a provider

## FAQ

### Do I have to get rid of BLoC or Scoped Model or Redux in my app to use Brick?

Nope. Those are _state_ managers. As a _store_ manager, Brick tracks and delivers persistent data across many sources, but it does not care about how you render that data. In fact, in its first app, Brick was integrated with BLoCs - the BLoC requested the data, Brick discovered the data, delivered the data back to the BLoC, and the BLoC delivered the data to the UI component for rendering.

As Repositories can output streams in `#getBatched`, a state manager could be easily bypassed. However, after trial and error, the Brick team determined the maintainence benefits of separating presentation and logic outweighed forgoing a state manager.

### What's in the name?

Brick isn't a state management library, it's a data _store_ management library. While Brick doesn't persist data itself, it routes data between different source. "Brick" plays on the adage "brick and mortar store."
