/// A class that isn't connected to the `OfflineFirstRepository` but is still used
/// by `OfflineFirstModels` (such as a `Cash` class that declares `amount` and `currency`).
/// [OfflineFirstSerdes] **must** extend the class in end implementation.
///
/// This is best used to `extends` non-primitive types that are not associations but still
/// need to be serialized and deserialized as a field.
///
/// A type parameters **are required**. For SQLite (second arg), these may be any of the
/// following: `bool`, `DateTime`, `double`, `int`, `num`, `String`. The Rest type supports the same
/// types in addition to `Iterable` and `Map`s digestible by [jsonEncode] and [jsonDecode].
///
/// Declare `factory` methods `fromSqlite` and `fromRest` to deserialize. Both use one unnamed
/// arg with a type post-`jsonDecode`.
abstract class OfflineFirstSerdes<_RestType, _SqliteType> {
  /// Pre-serialization to JSON. Must be digestible by `jsonEncode`.
  _RestType toRest() => null;

  /// Must be one of the following: `bool`, `DateTime`, `double`, `int`, `num`, `String`,
  /// or another `Iterable` digestible by `jsonEncode`.
  ///
  /// Often, [_SqliteType] is a `String` and `toSqlite` performs `jsonEncode(toRest())`.
  _SqliteType toSqlite() => null;

  // factory.fromRest(_RestType data) {}
  // factory.fromSqlite(_SqliteType data) {}
}
