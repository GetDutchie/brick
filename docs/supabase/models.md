# Model (Class) Configuration

## Annotations

### `@SupabaseSerializable(tableName:)`

The Supabase table name must be specified to connect `from`, `upsert` and `delete` invocations:

```dart
@SupabaseSerializable(tableName: 'users')
class User
```

### `@SupabaseSerializable(fieldRename:)`

By default, Brick assumes the Dart field name is the camelized version of the Supabase column name (i.e. `final String lastName => 'last_name'`). However, this can be changed to rename all fields.

```dart
@SupabaseSerializable(fieldRename: FieldRename.pascal)
class User
```

`fieldRename` is only the default transformation. Naming can be overriden on a field-by-field basis with `@Supabase(name:)`.

### `@SupabaseSerializable(defaultToNull:)`

Forwards to [Supabase's defaultToNull](https://supabase.com/docs/reference/dart/upsert) during `upsert` operations.

This would translate to approximate psuedo-code that Brick executes for you:

```dart
Supabase.instance.client.from('users')
  .upsert(user, defaultToNull: adapter.defaultToNull)
```

### `@SupabaseSerializable(ignoreDuplicates:)`

Forwards to [Supabase's ignoreDuplicates](https://supabase.com/docs/reference/dart/upsert) during `upsert` operations.

This would translate to approximate psuedo-code that Brick executes for you:

```dart
Supabase.instance.client.from('users')
  .upsert(user, defaultToNull: adapter.ignoreDuplicates)
```

### `@SupabaseSerializable(onConflict:)`

Forwards to [Supabase's onConflict](https://supabase.com/docs/reference/dart/upsert) during `upsert` operations.

This would translate to approximate psuedo-code that Brick executes for you:

```dart
Supabase.instance.client.from('users')
  .upsert(user, onConflict: adapter.onConflict)
```

## Upsert Behavior

The `SupabaseProvider` is unlike other providers. It recursively upserts associations because Supabase's API only accepts one row per table at a time.

For example, given model `Room` has association `Bed` and `Bed` has association `Pillow`, when `Room` is upserted, `Pillow` is upserted and then `Bed` is upserted.

The association models are upserted recursively before the requested instance is upserted. Because it's unknown if there has been any change from the local association to the remote association, all associations and their associations are upserted on a parent's upsert.

!> `delete` is not recursively invoked. If you need to cascade delete associations, enable `ON DELETE CASCADE` on the column in Supabase's database.
