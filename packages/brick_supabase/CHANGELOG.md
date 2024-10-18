## Unreleased

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
