import 'package:brick_graphql/graphql.dart';

/// [GraphqlSerializable] has `queryOperationTransformer`,
/// however, the function can't be re-interpreted by ConstantReader.
/// So the name is grabbed to be used in a later generator.
class GraphqlSerializableExtended extends GraphqlSerializable {
  final String? queryOperationTransformerName;

  const GraphqlSerializableExtended({
    FieldRename? fieldRename,
    this.queryOperationTransformerName,
  }) : super(fieldRename: fieldRename);
}
