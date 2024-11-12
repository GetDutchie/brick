## Unreleased

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
