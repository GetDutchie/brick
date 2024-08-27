import 'package:brick_core/core.dart';
import 'package:brick_core/field_rename.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/transformers/graphql_query_operation_transformer.dart';

/// An annotation used to specify a class to generate code for.
///
/// Creates a serialize/deserialize function for JSON.
///
/// Heavily borrowed/inspired by [JsonSerializable](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_serializable.dart)
class GraphqlSerializable {
  /// Defines the automatic naming strategy when converting class field names
  /// into JSON map keys.
  ///
  /// The value for `@Graphql(name:)` will override this convention.
  final FieldRename fieldRename;

  /// The interface used to determine the document to send GraphQL. This class
  /// will be accessed for all provider and repository operations.
  ///
  /// Implementing classes of [GraphqlQueryOperationTransformer] must be a `const`
  /// constructor. For simplicity, the default constructor tearoff can be provided
  /// as a value (`queryOperationTransformer: MyTransformer.new`).
  final GraphqlQueryOperationTransformer Function(Query?, GraphqlModel?)? queryOperationTransformer;

  /// Creates a new [GraphqlSerializable] instance.
  const GraphqlSerializable({
    FieldRename? fieldRename,
    this.queryOperationTransformer,
  }) : fieldRename = fieldRename ?? FieldRename.none;

  /// An instance of [GraphqlSerializable] with all fields set to their default
  /// values.
  static const defaults = GraphqlSerializable();
}
