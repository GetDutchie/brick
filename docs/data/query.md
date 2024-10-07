# Query

Filter local data using `Query`. Providers will use the `Query` to translate requested data into their query language. For the universality and legibility of SQL, that provider's translations will be used in the following examples but it is not the de facto query language of all providers.

## `where:`

When using `Query`, use the field name to find pertinent data instead of the column name. For example:

```dart
class User extends OfflineFirstModel {
  final SqliteAssociation association;
  @Sqlite(name: 'name')
  final String lastName;
}

// A query for all users with the last name "Mustermann":
Query.where('lastName', 'Mustermann') // note this is lastName and not name or last_name
```

Querying can be done with `Where` or `WherePhrase`:

1. `WherePhrase` is a collection of `Where` statements.
2. `WherePhrase` can't contain mixed `required:` because this will output invalid SQL. For example, when it's mixed: `WHERE id = 2 AND name = 'Thomas' OR name = 'Guy'`. The OR needs to be its own phrase: `WHERE (id = 2 AND name = 'Thomas') OR (name = 'Guy')`.
3. `WherePhrase` can be intermixed with `Where`.
   ```dart
   [
     Where('id').isExactly(2),
     WherePhrase([
       Or('name').isExactly('Guy'),
       Or('name').isExactly('Thomas')
     ], required: false)
   ]
   // => (id == 2) || (name == 'Thomas' || name == 'Guy')
   ```

!> Queried enum values should map to a primitive. Plainly, **always include `.index`**: `Where('type').isExactly(MyEnumType.value.index)`.

### Associations

`providerArgs` are forwarded to the provider which chooses to accept or reject specific keys. For example, Rest accepts the `headers` key to control request headers. SQLite supports operators like `groupBy`, `orderBy`, `offset`, and others in its `providerArgs`.

When querying associations, use a nested `Where`, again searching by field name on the association. For example:

```dart
Query(where: [
  Where('association').isExactly(
    Where('name').isExactly('Thomas'),
  ),
])
```

### `compare:`

Fields can be compared to their values beyond an exact match (the default).

```dart
Where('name', value: 'Thomas', compare: Compare.contains);
```

- `between`
- `contains`
- `doesNotContain`
- `exact`
- `greaterThan`
- `greaterThanOrEqualTo`
- `lessThan`
- `lessThanOrEqualTo`
- `notEqual`

Please note that the provider is ultimately responsible for supporting `Where` queries.

### `required:`

Conditions that are required must evaluate to true for the query to satisfy. They can be specified individually:

```dart
Query(where: [
  Where('name', value: 'Thomas', required: true),
  And('age').isExactly(42),
])
// => name == 'Thomas' && age == 42
```

Or specified as a whole phrase:

```dart
Query(where: [
  WherePhrase([
    Where('name', value: 'Thomas', required: false),
    Where('age', value: 42, compare: Compare.notEqual, required: false),
  ], required: true),
  WherePhrase([
    Where('height', value: [182, 186], compare: Compare.between),
    Where('country', value: 'France'),
  ], required: true)
])
// =>  (name == 'Thomas' || age != 42) && (height > 182 && height < 186 && country == 'France')
```

?> If expanded `WherePhrase`s become illegible, helpers `And` and `Or` can be used:

```dart
Query(where: [
  AndPhrase([
    Or('name').isExactly('Thomas'),
    Or('age').isNot(42),
  ]),
  AndPhrase([
    And('height').isBetween(182, 186),
    And('country').isExactly('France'),
  ]),
])
// =>  (name == 'Thomas' || age != 42) && (height > 182 && height < 186 && country == 'France')
```

## Filtering

In the provider (or even a REST endpoint), convenience methods are available to quickly interpret a query.

### `Where.byField`

Find conditions that evaluate a specific field. A field is a member on a model, such as `myUserId` in `final String myUserId`. If the use case for the field only requires one result, say `id` or `primaryKey`, `Where.firstByField` may be more useful.

```dart
Where.byField('lastName', query.where);
```

### `Where.firstByField`

Find the first occurrance of a condition that evaluates a specific field. This is useful when querying for a unique record. For all conditions, use `Where.byField`.

```dart
final condition = Where.firstByField('id', query.where);
final id = condition?.value;
```
