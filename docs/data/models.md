# Models

Models are business logic unique to the app. Fetched by the `Repository`, and if merited by the `Repository` implementation, the `Provider`.

## Setup

Every model must be decorated by an annotation and extend a base type that the repository manages:

```dart
@ConnectOfflineFirstWithRest()
class User extends OfflineFirstModel {}
```

The primary constructor of the model **must** include named arguments for all serialized fields. Brick **does not support** unnamed constructor arguments. This is an opinionated choice that enables the adapters to reliably return a hydrated model. The constructor may elect to mutate input data, but the named arguments **must be present**:

```dart
class Hat extends OfflineFirstModel {
  final String color;
  final int width;

  Hat({
    this.color,
    int width,
  }) : width = (width ?? 0) + 1;
}
```

?> Every `import` in a model definition file will be copied to `brick.g.dart` and available to the adapters. This is useful for field-level generators or class-level annotations that stringified functions (`RestSerializable#endpoint`).
