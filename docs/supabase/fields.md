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

### `@Supabase(foreignKey:)`

Specify the foreign key to use on the table when fetching for a remote association.

For example, given the `orders` table has a `customer_id` column that associates the `customers` table, an `Order` class in Dart may look like:

```dart
@SupabaseSerializeable(tableName: 'orders')
class Order {
  @Supabase(foreignKey: 'customer_uuid')
  final Customer customer;
}

@SupabaseSerializeable(tableName: 'customers')
class Customer {
  @Supabase(unique: true)
  final String uuid;
}
```

### `@Supabase(name:)`

Supabase keys can be renamed per field. This will override the default set by `SupabaseSerializable#fieldRename`.

```dart
@Supabase(
  name: "full_name"  // "full_name" is used in from and to requests to Supabase instead of "last_name"
)
final String lastName;
```

?> By default, Brick renames fields to be snake case when translating to Supabase, but you can change this default in the `@SupabaseSerializable(fieldRename:)` annotation that [decorates models](models.md).

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
