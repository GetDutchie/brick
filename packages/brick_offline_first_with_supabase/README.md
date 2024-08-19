![brick_offline_first_with_supabase workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_offline_first_with_supabase.yaml/badge.svg)

`OfflineFirstWithSupabaseRepository` streamlines the Supabase integration with an `OfflineFirstRepository`.

The `OfflineFirstWithSupabase` domain uses all the same configurations and annotations as `OfflineFirst`.

## Models

### ConnectOfflineFirstWithSupabase

`@ConnectOfflineFirstWithSupabase` decorates the model that can be serialized by one or more providers. Offline First does not have configuration at the class level and only extends configuration held by its providers:

```dart
@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
  sqliteConfig: SqliteSerializable(),
)
class MyModel extends OfflineFirstModel {}
```

### FAQ

#### Why can't I declare a model argument?

Due to [an open analyzer bug](https://github.com/dart-lang/sdk/issues/38309), a custom model cannot be passed to the repository as a type argument.

## Unsupported Field Types

- Any unsupported field types from `SupabaseProvider`, or `SqliteProvider`
- Future iterables of future models (i.e. `Future<List<Future<Model>>>`).
