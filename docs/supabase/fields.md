# Field Configuration

## Annotations

### `@Supabase(unique:)`

Connect Supabase's primary key (or any other uniquely-defined index) to your application code. This is useful for `upsert` and `delete` logic when mutating instances.

```dart
@Supabase(unique: true, name: 'uuid')
final String supabaseUuid;
```

This would translate to approximate psuedo-code that Brick executes for you:

```dart
Supabase.instance.client.from('users')
  .upsert(user).eq('uuid', instance.uuid)
```

### `@Supabase(name:)`

Supabase keys can be renamed per field. This will override the default set by `SupabaseSerializable#fieldRename`.

```dart
// "full_name" is used in from and to requests to Supabase instead of "last_name"
@Supabase(name: "full_name")
final String lastName;
```

?> By default, Brick renames fields to be snake case when translating to Supabase, but you can change this default in the `@SupabaseSerializable(fieldRename:)` annotation that [decorates models](models.md).

!> **Do not use** `name` when annotating an association. Instead, use `foreignKey`.

### `@Supabase(foreignKey:)`

When the annotated field references a `OfflineFirstWithSupabaseModel`, a foreign key can be specified. Supabase's PostgREST API can usually determine the association without specifying the foreign key. However, [when multiple foreign keys exist](https://supabase.com/docs/guides/database/joins-and-nesting?queryGroups=language&language=dart#specifying-the-on-clause-for-joins-with-multiple-foreign-keys) to the same table, guiding Brick to use the right foreign key is required.

```dart
class User extends OfflineFirstWithSupabaseModel{
  @Supabase(foreignKey: 'address_id')
  final Address address;
}

class Address extends OfflineFirstWithSupabaseModel{
  final String id;
}
```

?> The remote column type can be different than the local Dart type for associations. For example, `@Supabase(name: 'user_id')` that annotates `final User user` can be a Postgres string type.

### `@Supabase(enumAsString:)`

Brick by default assumes enums from a Supabase API will be delivered as integers matching the index in the Flutter app. However, if your API delivers strings instead, the field can be easily annotated without writing a custom generator.

Given the API:

```json
{ "user": { "hats": ["bowler", "birthday"] } }
```

Simply convert `hats` into a Dart enum:

```dart
enum Hat { baseball, bowler, birthday }

...

@Supabase(enumAsString: true)
final List<Hat> hats;
```

### `@Supabase(ignoreFrom:)` and `@Supabase(ignoreTo:)`

When true, the field will be ignored by the (de)serializing function in the adapter.

## Unsupported Field Types

The following are not serialized to Supabase. However, unsupported types can still be accessed in the model as non-final fields.

- Nested `List<>` e.g. `<List<List<int>>>`
- Many-to-many associations
