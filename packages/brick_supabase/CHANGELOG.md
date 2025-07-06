## 2.1.0

- Add `SupabaseProvider#subscribeToRealtime` to subscribe to [Supabase channels](https://supabase.com/docs/guides/realtime?queryGroups=language&language=dart).
- Add `SupabaseProvider#queryToPostgresChangeFilter` to convert `Query`s for Supabase subscriptions

## 2.0.0

- **BREAKING CHANGE** `Query(providerArgs:)` is no longer supported; see [1.2.0](#1.2.0) for migration steps
- **BREAKING CHANGE** `Supabase(nullable:)` is no longer supported; see [1.4.0](#1.4.0) for migration steps
- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.

## 1.4.1+1

- Add `SupabaseProviderQuery`
- Support defining `upsertMethod` via `SupabaseProviderQuery`
- Fix `orderBy` queries to use the column name instead of the field name when constructing PostgREST queries

## 1.4.0

- **DEPRECATION** remove `Supabase#nullable`. Builders should evaluate the nullable suffix of the field instead

## 1.3.0

- When testing realtime responses, `realtime: true` must be defined in `SupabaseRequest`. This also resolves a duplicate `emits` bug in tests; the most common resolution is to remove the first duplicated expected response (e.g. `emitsInOrder([[], [], [resp]])` becomes `emitsInOrder([[], [resp]])`)
- Associations are not serialized in the `SupabaseResponse`; only subscribed table data is provided

## 1.2.0

- **DEPRECATION** `Query(providerArgs: {'limitReferencedTable':})` has been removed in favor of `Query(limitBy:)` #510
- **DEPRECATION** `Query(providerArgs: {'orderByReferencedTable':})` has been removed in favor of `Query(orderBy:)` #510
- Association, plural ordering is supported. For example, `Query(orderBy: [OrderBy.desc('assoc', associationField: 'name')])` on `DemoModel` would produce the PostgREST filter:
  ```javascript
  orderBy('name', referencedTable: 'association_table')
  ```
- New `SupabaseProviderQuery` adds Supabase-specific support for the new `Query`.
- Advanced, plural limiting is supported. For example, `Query(limitBy: [LimitBy(1, evaluatedField: 'assoc'))` is the equivalent of `.limit(1, referencedTable: 'demo_model')`. `Query#limit` can be used in conjunction on the parent model request.
- Upgrade `brick_core` to `1.3.0`
- Update analysis to modern lints
- Add `SupabaseProvider#update` and `SupabaseProvider#insert` to conform to Supabase policy restrictions
- Use `columnName` instead of `evaluatedField` in `QuerySupabaseTransformer` when searching for non null associations

## 1.1.3

- Add `query:` to `@Supabase` to override the generated query at runtime
- Support `@Supabase(query:)` in `QuerySupabaseTransformer` and `RuntimeSupabaseColumnDefinition`

## 1.1.2

- Add `'offset'` to Supabase's handled `Query(providerArgs:)`

## 1.1.1

- Fix a query builder infinite recursion bug where a parent has a child that has a parent association
- Use declared Supabase `columnName` when requesting an association from Supabase
- Do not declare a `:tableName` on a Supabase query if no table name is available on the adapter. This should never happen since the code is generated

## 1.1.0

- Reorganized `testing.dart` to `src/testing`
- Added support for stream mocking to `SupabaseMockServer`

## 1.0.5

- Add `onConflict` to `SupabaseProvider#upsert` requests (#467) @sonbs21

## 1.0.4

- Expose private methods `SupabaseProvider#upsertByType` and `SupabaseProvider#recursiveAssociationUpsert` as protected methods

## 1.0.3

- Remove `select` from `#delete`

## 1.0.2

- Only specify key lookup in query transformer if `RuntimeSupabaseColumnDefinition#foreignKey` is specified

## 1.0.1

- Add `@Supabase(foreignKey:)` to specify association querying
- Add `RuntimeSupabaseColumnDefinition#foreignKey` to track `@Supabase(foreignKey:)` values

## 1.0.0

- Stable release

## 0.1.1

- Resolve `QuerySupabaseTransformer` bugs
- Fix table name collision in offline adapter (#416)

## 0.1.0

- Alpha release

## 0.0.1

- Initial
