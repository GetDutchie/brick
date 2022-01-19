import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/provider_serializable_generator.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql_generators/src/graphql_deserialize.dart';
import 'package:brick_graphql_generators/src/graphql_serialize.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_rest/rest.dart' show RestSerializable, FieldRename;

/// Digest a `restConfig` (`@ConnectOfflineFirstWithRest`) from [reader] and manage serdes generators
/// to and from a `RestProvider`.
class GraphqlModelSerdesGenerator extends ProviderSerializableGenerator<RestSerializable> {
  /// Repository prefix passed to the generators. `Repository` will be appended and
  /// should not be included.
  final String repositoryName;

  GraphqlModelSerdesGenerator(
    Element element,
    ConstantReader reader, {
    required this.repositoryName,
  }) : super(element, reader, configKey: 'graphqlConfig');

  @override
  RestSerializable get config {
    if (reader.peek(configKey) == null) {
      return RestSerializable.defaults;
    }

    final fieldRenameObject = withinConfigKey('fieldRename')?.objectValue;
    final fieldRenameByEnumName = _firstWhereOrNull(
      FieldRename.values,
      (f) => fieldRenameObject?.getField(f.toString().split('.')[1]) != null,
    );

    return GraphqlSerializable(
      nullable: withinConfigKey('nullable')?.boolValue ?? RestSerializable.defaults.nullable,
      fieldRename: fieldRenameByEnumName ?? RestSerializable.defaults.fieldRename,
      endpoint: withinConfigKey('endpoint')?.stringValue ?? RestSerializable.defaults.endpoint,
      fromKey: withinConfigKey('fromKey')?.stringValue ?? RestSerializable.defaults.fromKey,
      toKey: withinConfigKey('toKey')?.stringValue ?? RestSerializable.defaults.toKey,
    );
  }

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = RestFields(classElement, config);
    return [
      GraphqlDeserialize(classElement, fields, repositoryName: repositoryName),
      GraphqlSerialize(classElement, fields, repositoryName: repositoryName),
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
