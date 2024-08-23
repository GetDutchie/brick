![brick_supabase workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_supabase.yaml/badge.svg)

# Supabase Provider

Connecting [Brick](https://github.com/GetDutchie/brick) with Supabase.

## Supported `Query` Configuration

### `providerArgs:`

- `'limit'` e.g. `{'limit': 10}`
- `'limitByReferencedTable' forwards to Supabase's `referencedTable` property https://supabase.com/docs/reference/dart/limit
- `'orderBy'` Use field names not column names and always specify direction.For example, given a `final DateTime createdAt;` field: `{'orderBy': 'createdAt ASC'}`.
  If the column cannot be found for the first value before a space, the value is left unchanged.
- `'orderByReferencedTable'` forwards to Supabase's `referencedTable` property https://supabase.com/docs/reference/dart/order

## Models

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

## Fields

### `@Supabase(unique:)`

Connect Supabase's primary key (or any other index) to your application code. This is useful for `upsert` and `delete` logic when mutating instances.

```dart
@Supabase(unique: true, name: 'uuid')
final String supabaseUuid;
```

### `@Supabase(foreignKey:)`

Specify the foreign key to use on the table when fetching for a remote association.

For example, given the `orders` table has a `customer_id` column that associates
the `customers` table, an `Order` class in Dart may look like:

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

### `@Supabase(enumAsString:)`

Brick by default assumes enums from a REST API will be delivered as integers matching the index in the Flutter app. However, if your API delivers strings instead, the field can be easily annotated without writing a custom generator.

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

### `@Supabase(name:)`

REST keys can be renamed per field. This will override the default set by `SupabaseSerializable#fieldRename`.

```dart
@Supabase(
  name: "full_name"  // "full_name" is used in from and to requests to REST instead of "last_name"
)
final String lastName;
```

### `@Supabase(ignoreFrom:)` and `@Supabase(ignoreTo:)`

When true, the field will be ignored by the (de)serializing function in the adapter.

## Unsupported Field Types

The following are not serialized to REST. However, unsupported types can still be accessed in the model as non-final fields.

- Nested `List<>` e.g. `<List<List<int>>>`
- Many-to-many associations