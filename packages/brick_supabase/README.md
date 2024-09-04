![brick_supabase workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_supabase.yaml/badge.svg)

# Supabase Provider

Connecting [Brick](https://github.com/GetDutchie/brick) with Supabase.

## Supported `Query` Configuration

### `providerArgs:`

| Name                       | Type      | Description                                                                                                                                           |
| -------------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `'limit'`                  | `int`     | Forwards to Supabase's `limit` [param](https://supabase.com/docs/reference/dart/limit) in Brick's `#get` action                                       |
| `'limitByReferencedTable'` | `String?` | Forwards to Supabase's `referencedTable` [property](https://supabase.com/docs/reference/dart/limit)                                                   |
| `'orderBy'`                | `String`  | Use field names not column names and always specify direction.For example, given a `final DateTime createdAt;` field: `{'orderBy': 'createdAt ASC'}`. |
| `'orderByReferencedTable'` | `String?` | Forwards to Supabase's `referencedTable` [property](https://supabase.com/docs/reference/dart/order)                                                   |

:bulb: The `ReferencedTable` params are awkward but necessary to not collide with other providers (like `SqliteProvider`) that also use `orderBy` and `limit`. While a `foreign_table.foreign_column` syntax is more Supabase-like, it is not supported in `orderBy` and `limit`.

### `where:`

Brick currently does not support all of Supabase's filtering methods. Consider the associated `Compare` enum value to Supabase's method when building a Brick query:

| Brick                          | Supabase    |
| ------------------------------ | ----------- |
| `Compare.exact`                | `.eq`       |
| `Compare.notEqual`             | `.neq`      |
| `Compare.contains`             | `.like`     |
| `Compare.doesNotContain`       | `.not.like` |
| `Compare.greaterThan`          | `.gt`       |
| `Compare.greaterThanOrEqualTo` | `.gte`      |
| `Compare.lessThen`             | `.lt`       |
| `Compare.lessThenOrEqualTo`    | `.lte`      |
| `Compare.between`              | `.adj`      |

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

### `@SupabaseSerializable(defaultToNull:)`

Forwards to [Supabase's defaultToNull](https://supabase.com/docs/reference/dart/upsert) during `upsert` operations.

### `@SupabaseSerializable(ignoreDuplicates:)`

Forwards to [Supabase's ignoreDuplicates](https://supabase.com/docs/reference/dart/upsert) during `upsert` operations.

### `@SupabaseSerializable(onConflict:)`

Forwards to [Supabase's onConflict](https://supabase.com/docs/reference/dart/upsert) during `upsert` operations.

## Fields

### `@Supabase(unique:)`

Connect Supabase's primary key (or any other index) to your application code. This is useful for `upsert` and `delete` logic when mutating instances.

```dart
@Supabase(unique: true, name: 'uuid')
final String supabaseUuid;
```

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

### `@Supabase(name:)`

Supabase keys can be renamed per field. This will override the default set by `SupabaseSerializable#fieldRename`.

```dart
@Supabase(
  name: "full_name"  // "full_name" is used in from and to requests to Supabase instead of "last_name"
)
final String lastName;
```

:bulb: By default, Brick renames fields to be snake case when translating to Supabase, but you can change this default in the `@SupabaseSerializable(fieldRename:)` annotation that [decorates models](models.md).

When the annotated field type extends the model's type, the Supabase column should be a foreign key.

```dart
class User extends OfflineFirstWithSupabaseModel{
  // The foreign key is a relation to the `id` column of the Address table
  @Supabase(name: 'address_id')
  final Address address;
}

class Address extends OfflineFirstWithSupabaseModel{
  final String id;
}
```

:bulb: The remote column type can be different than the local Dart type for associations. For example, `@Supabase(name: 'user_id')` that annotates `final User user` can be a Postgres string type.

### `@Supabase(ignoreFrom:)` and `@Supabase(ignoreTo:)`

When true, the field will be ignored by the (de)serializing function in the adapter.

## Unsupported Field Types

The following are not serialized to Supabase. However, unsupported types can still be accessed in the model as non-final fields.

- Nested `List<>` e.g. `<List<List<int>>>`
- Many-to-many associations
