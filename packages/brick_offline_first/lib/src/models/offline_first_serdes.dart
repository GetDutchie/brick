import 'dart:convert';

/// A class that isn't connected to the `OfflineFirstRepository` but is still used
/// by `OfflineFirstModels` (such as a `Cash` class that declares `amount` and `currency`).
/// [OfflineFirstSerdes] **must** extend the class in end implementation.
///
/// This is best used to `extends` non-primitive types that are not associations but still
/// need to be serialized and deserialized as a field.
///
/// Type parameters **are required**. For [SqliteSerializeType] (second arg), these may be any of the
/// following: `bool`, `DateTime`, `double`, `int`, `num`, `String`. [RemoteSerializeType]
/// should support the same types in addition to `Iterable` and `Map`s digestible by [jsonEncode]
/// and [jsonDecode] unless otherwise specified.
///
/// Declare `factory` methods `fromSqlite` and `from<REMOTE PROIVDER(s)>` (like `fromRest`) to deserialize.
/// Both use one unnamed arg with a type post-`jsonDecode`.
abstract class OfflineFirstSerdes<RemoteSerializeType, SqliteSerializeType> {
  /// Pre-serialization to JSON. Must be digestible by `jsonEncode`.
  RemoteSerializeType? toGraphql() => null;

  /// Pre-serialization to JSON. Must be digestible by `jsonEncode`.
  RemoteSerializeType? toRest() => null;

  /// Pre-serialization to JSON. Must be digestible by `jsonEncode`.
  RemoteSerializeType? toSupabase() => null;

  /// Must be one of the following: `bool`, `DateTime`, `double`, `int`, `num`, `String`,
  /// or another `Iterable` digestible by `jsonEncode`.
  ///
  /// Often, [SqliteSerializeType] is a `String` and `toSqlite` performs `jsonEncode(toRest())`.
  SqliteSerializeType? toSqlite() => null;

  // factory.fromSqlite(SqliteSerializeType data) {}
}
