import 'package:analyzer/dart/element/element.dart';
// ignore: implementation_imports
import 'package:brick_build/src/provider_serializable_generator.dart';
// ignore: implementation_imports
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql_generators/src/graphql_deserialize.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_graphql_generators/src/graphql_serialize.dart';
import 'package:gql/ast.dart' show DocumentNode;
import 'package:source_gen/source_gen.dart';

/// Digest a `graphqlConfig` (`@ConnectOfflineFirstWithGraphQL`) from [reader] and manage serdes generators
/// to and from a `GraphQLProvider`.
class GraphQLModelSerdesGenerator extends ProviderSerializableGenerator<GraphQLSerializable> {
  /// Repository prefix passed to the generators. `Repository` will be appended and
  /// should not be included.
  final String repositoryName;

  GraphQLModelSerdesGenerator(
    Element element,
    ConstantReader reader, {
    required this.repositoryName,
  }) : super(element, reader, configKey: 'graphqlConfig');

  @override
  GraphQLSerializable get config {
    if (reader.peek(configKey) == null) {
      return GraphQLSerializable.defaults;
    }

    final fieldRenameObject = withinConfigKey('fieldRename')?.objectValue;
    final fieldRenameByEnumName = _firstWhereOrNull(
      FieldRename.values,
      (f) => fieldRenameObject?.getField(f.toString().split('.')[1]) != null,
    );

    return GraphQLSerializable(
      fieldRename: fieldRenameByEnumName ?? GraphQLSerializable.defaults.fieldRename,
      mutationDocument: withinConfigKey('mutationDocument')?.literalValue as DocumentNode?,
    );
  }

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = GraphQLFields(classElement, config);
    return [
      GraphQLDeserialize(classElement, fields, repositoryName: repositoryName),
      GraphQLSerialize(classElement, fields, repositoryName: repositoryName),
    ];
  }
}

// from dart:collections, instead of importing a whole package
T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (var item in items) {
    if (test(item)) return item;
  }
  return null;
}
