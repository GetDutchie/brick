## 2.1.0

- Use `SupabaseProvider#subscribeToRealtime` to generate the channel used by `OfflineFirstWithSupabaseRepository#subscribeToRealtime`
- **Breaking Change** protected method `OfflineFirstWithSupabaseRepository#queryToPostgresChangeFilter` has been moved to `SupabaseProvider#queryToPostgresChangeFilter`. Implementations should override this method in `SupabaseProvider` instead.

## 2.0.0

- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.

## 1.3.0

- If a model requested in a realtime subscription has an association, an extra fetch is performed (#514)

## 1.2.0

- Upgrade `brick_core` to `1.3.0`
- Update analysis to modern lints

## 1.1.2

- Support a custom database path when creating the cache manager (#490)

## 1.1.1

- Allow a generic type argument for `OfflineFirstWithSupabaseRepository`

## 1.1.0

- Added `OfflineFirstWithSupabaseRepository#subscribeToRealtime`to sync Brick data with Supabase changes (#472, #454)

## 1.0.0

- Stable release

## 0.1.0

- Alpha release

## 0.0.1

- Initial
