/// Values for the automatic field renaming behavior for [RestSerializable].
///
/// Heavily borrowed/inspired by [JsonSerializable](https://github.com/dart-lang/json_serializable/blob/a581e5cc9ee25bf4ad61e8f825a311289ade905c/json_serializable/lib/src/json_key_utils.dart#L164-L179)
enum FieldRename {
  /// Leave fields unchanged
  none,

  /// Encodes field name from `snakeCase` to `snake_case`.
  snake,

  /// Encodes field name from `kebabCase` to `kebab-case`.
  kebab,

  /// Capitalizes first letter of field name
  pascal,
}

/// An annotation used to specify a class to generate code for.
///
/// Creates a serialize/deserialize function for JSON.
///
/// Heavily borrowed/inspired by [JsonSerializable](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_serializable.dart)
class RestSerializable {
  /// Callback to produce a REST path from a [Query]. An `instance` argument is provided
  /// **only when** it is available to the invoking repository method (i.e. `upsert` or `delete`).
  ///
  /// This must be a string to maintain `const`-ability of the annotation.
  /// It should adhere to the standard of [RestEndpointCallback] and include a line
  /// termination (`;` or `}`).
  ///
  /// **Example**:
  /// ```dart
  /// ({Query query, Model instance}) {
  ///   if (query.params['limit'] == 1) {
  ///     return "person/${query.params['id']}";
  ///   }
  ///
  ///   return "people";
  /// }
  /// ```
  ///
  /// Should be included as
  /// ```dart
  /// endpoint: r"""{
  ///   if (query.params['limit'] == 1) {
  ///     return "person/${query.params['id']}";
  ///   }
  ///
  ///   return "people";
  /// }"""
  /// ```
  ///
  /// This function will serve all remote commands from the repository.
  /// To determine which is being invoked, use `query.action`.
  ///
  /// This field is copied to the [Adapter].
  final String endpoint;

  /// Defines the automatic naming strategy when converting class field names
  /// into JSON map keys.
  ///
  /// The value for `@Rest(name:)` will override this convention.
  final FieldRename fieldRename;

  /// When deserializing from REST, the response may be nested within a top level key.
  /// If no key is defined, the first value will be returned. This configuration is overriden
  /// when a query specifies `params['topLevelKey']`.
  ///
  /// **Example**
  /// Given the API:
  /// ```
  /// { "users" : {"id" : 1, "name" : "Thomas" }}
  /// ```
  /// The [fromKey] would be `"users"`.
  ///
  /// This field is copied to the [Adapter].
  final String fromKey;

  /// When `true` (the default), `null` fields are handled gracefully when decoding `null`
  /// and nonexistent values from JSON.
  ///
  /// Setting to `false` eliminates `null` verification in the generated code,
  /// which reduces the code size. Errors may be thrown at runtime if `null`
  /// values are encountered, but the original class should also implement
  /// `null` runtime validation if it's critical. Defaults to `false`.
  final bool nullable;

  /// When serializing to REST, the payload may need to be nested within a top level key.
  ///
  /// **Example**
  /// Given the desired payload:
  /// ```
  /// { "user" : {"id" : 1, "name" : "Thomas" }}
  /// ```
  /// The [toKey] would be `"user"`.
  ///
  /// This field is copied to the [Adapter].
  final String toKey;

  /// Creates a new [RestSerializable] instance.
  const RestSerializable({
    this.endpoint,
    this.fieldRename,
    this.fromKey,
    this.nullable,
    this.toKey,
  });

  /// An instance of [RestSerializable] with all fields set to their default
  /// values.
  static const defaults = RestSerializable(
    fieldRename: FieldRename.snake,
    nullable: false,
  );
}
