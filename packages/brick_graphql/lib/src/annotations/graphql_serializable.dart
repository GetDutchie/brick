import 'package:brick_rest/rest.dart';
import 'package:gql/ast.dart';

/// An annotation used to specify a class to generate code for.
///
/// Creates a serialize/deserialize function for JSON.
///
/// Heavily borrowed/inspired by [JsonSerializable](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_serializable.dart)
class GraphQLSerializable extends RestSerializable {
  /// Defines the automatic naming strategy when converting class field names
  /// into JSON map keys.
  ///
  /// The value for `@GraphQL(name:)` will override this convention.
  final FieldRename fieldRename;

  /// The query for transmitting a mutated payload.
  ///
  /// If this model is fetch-only the value should remain `null`.
  final DocumentNode? mutationDocument;

  /// Creates a new [GraphQLSerializable] instance.
  const GraphQLSerializable({
    this.mutationDocument,
    FieldRename? fieldRename,
  }) : fieldRename = fieldRename ?? FieldRename.none;

  /// An instance of [GraphQLSerializable] with all fields set to their default
  /// values.
  static const defaults = GraphQLSerializable();
}
