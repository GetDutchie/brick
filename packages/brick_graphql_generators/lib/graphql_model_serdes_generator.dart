import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart' show ProviderSerializableGenerator, SerdesGenerator;
import 'package:brick_core/field_rename.dart';
import 'package:brick_graphql/brick_graphql.dart' show GraphqlSerializable;
import 'package:brick_graphql_generators/src/graphql_deserialize.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_graphql_generators/src/graphql_serializable_query_transformer_extended.dart';
import 'package:brick_graphql_generators/src/graphql_serialize.dart';

/// Digest a `graphqlConfig` (`@ConnectOfflineFirstWithGraphQL`) from [reader] and manage serdes generators
/// to and from a `GraphqlProvider`.
class GraphqlModelSerdesGenerator
    extends ProviderSerializableGenerator<GraphqlSerializableExtended> {
  /// Repository prefix passed to the generators. `Repository` will be appended and
  /// should not be included.
  final String repositoryName;

  /// Digest a `graphqlConfig` (`@ConnectOfflineFirstWithGraphQL`) from [reader] and manage serdes generators
  /// to and from a `GraphqlProvider`.
  GraphqlModelSerdesGenerator(
    super.element,
    super.reader, {
    required this.repositoryName,
  }) : super(configKey: 'graphqlConfig');

  @override
  GraphqlSerializableExtended get config {
    if (reader.peek(configKey) == null) {
      return const GraphqlSerializableExtended();
    }

    final fieldRenameIndex =
        withinConfigKey('fieldRename')?.objectValue.getField('index')?.toIntValue();
    final fieldRename = fieldRenameIndex != null ? FieldRename.values[fieldRenameIndex] : null;
    final function = withinConfigKey('queryOperationTransformer')?.objectValue.toFunctionValue();
    var functionName = function?.enclosingElement3.name;
    if (function is ConstructorElement) {
      functionName = '$functionName.new';
    }

    return GraphqlSerializableExtended(
      fieldRename: fieldRename ?? GraphqlSerializable.defaults.fieldRename,
      queryOperationTransformerName: functionName,
    );
  }

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = GraphqlFields(classElement, config);
    return [
      GraphqlDeserialize(classElement, fields, repositoryName: repositoryName),
      GraphqlSerialize(classElement, fields, repositoryName: repositoryName),
    ];
  }
}
