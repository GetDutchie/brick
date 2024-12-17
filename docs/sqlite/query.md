# `Query` Configuration

## `providerArgs`

The following map exactly to their SQLite keywords. The values will be inserted into a SQLite statement **without being prepared**.

- `collate`
- `having`
- `groupBy`
- `limit`
- `offset`
- `orderBy`

As the values are directly inserted, use the field name:

```dart
//given this field
@Sqlite(name: 'last_name')
final String lastName;

Query(
  where: [Where.exact('lastName', 'Mustermann')],
  orderBy: [OrderBy('lastName', ascending: true)]
)
```

## `where:`

All fields and associations are supported. All `Compare` values are also supported without additional configuration.
