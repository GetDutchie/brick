# `Query` Configuration

## `limit`

Forwards to Supabase's `limit` [param](https://supabase.com/docs/reference/dart/limit) in Brick's `#get` action

## `offset`

Start from a specific offset, inclusive.

## `providerArgs:`

| Name                       | Type      | Description                                                                                         |
| -------------------------- | --------- | --------------------------------------------------------------------------------------------------- | --- |
| `'limitByReferencedTable'` | `String?` | Forwards to Supabase's `referencedTable` [property](https://supabase.com/docs/reference/dart/limit) |     |
| `'orderByReferencedTable'` | `String?` | Forwards to Supabase's `referencedTable` [property](https://supabase.com/docs/reference/dart/order) |

?> The `ReferencedTable` naming convention is awkward but necessary to not collide with other providers (like `SqliteProvider`) that also use `orderBy` and `limit`. While a `foreign_table.foreign_column` syntax is more Supabase-like, it is not supported in `orderBy` and `limit`.

## `where:`

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
