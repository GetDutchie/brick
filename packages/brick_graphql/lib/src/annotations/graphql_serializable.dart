/// Values for the automatic field renaming behavior for [GraphqlSerializable].
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
class GraphqlSerializable {
  /// The mutation used to remove data.
  /// Only the header of the operation is required. For example
  /// ```graphql
  /// mutation DeletePerson($input: DeletePersonInput!) {
  ///   deletePerson(input: $input) {}
  /// }
  /// ```
  final String? defaultDeleteOperation;

  /// The query used to fetch multiple member.
  /// Only the header of the operation is required. For example
  /// ```graphql
  /// query GetPeople() {
  ///   getPerson() {}
  /// }
  /// ```
  final String? defaultGetUnfilteredOperation;

  /// The query used to fetch a member.
  /// Only the header of the operation is required. For example
  /// ```graphql
  /// query GetPerson($input: GetPersonInput!) {
  ///   getPerson(input: $input) {}
  /// }
  /// ```
  final String? defaultGetFilteredOperation;

  /// The mutation used to create or update a member.
  /// Only the header of the operation is required. For example
  /// ```graphql
  /// query UpsertPerson($input: PersonInput!) {
  ///   upsertPerson(input: $input) {}
  /// }
  /// ```
  final String? defaultUpsertOperation;

  /// Defines the automatic naming strategy when converting class field names
  /// into JSON map keys.
  ///
  /// The value for `@Graphql(name:)` will override this convention.
  final FieldRename fieldRename;

  /// Creates a new [GraphqlSerializable] instance.
  const GraphqlSerializable({
    this.defaultDeleteOperation,
    this.defaultGetUnfilteredOperation,
    this.defaultGetFilteredOperation,
    this.defaultUpsertOperation,
    FieldRename? fieldRename,
  }) : fieldRename = fieldRename ?? FieldRename.none;

  /// An instance of [GraphqlSerializable] with all fields set to their default
  /// values.
  static const defaults = GraphqlSerializable();
}
