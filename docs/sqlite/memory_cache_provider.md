# Memory Cache Provider

The Memory Cache Provider is a key-value store that functions based on the SQLite primary keys to optimize the SQLite provider queries. This is especially effective for low-level associations. The provider only caches models it's aware of:

```dart
// app models: `User`, `Hat`
MemoryCacheProvider([Hat])
// `User` is never stored in memory
```

It is not recommended to use this provider with parent models that have child associations, as those children may be updated in the future without notifying the parent.
