import 'package:brick_graphql/brick_graphql.dart';

/// [GraphqlSerializable] has `queryOperationTransformer`,
/// however, the function can't be re-interpreted by ConstantReader.
/// So the name is grabbed to be used in a later generator.
class GraphqlSerializableExtended extends GraphqlSerializable {
  /// The interface used to determine the document to send GraphQL. This class
  /// will be accessed for all provider and repository operations.
  ///
  /// Implementing classes of [GraphqlQueryOperationTransformer] must be a `const`
  /// constructor. For simplicity, the default constructor tearoff can be provided
  /// as a value (`queryOperationTransformer: MyTransformer.new`).
  final String? queryOperationTransformerName;

  /// [GraphqlSerializable] has `queryOperationTransformer`,
  /// however, the function can't be re-interpreted by ConstantReader.
  /// So the name is grabbed to be used in a later generator.
  const GraphqlSerializableExtended({
    super.fieldRename,
    this.queryOperationTransformerName,
  });
}
