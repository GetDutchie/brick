import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/provider_serializable.dart';
import 'package:brick_build/src/rest_serdes/rest_deserialize.dart';
import 'package:brick_build/src/rest_serdes/rest_fields.dart';
import 'package:brick_build/src/rest_serdes/rest_serialize.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_rest/rest.dart' show RestSerializable, FieldRename;

/// Digest a `restConfig` (`@ConnectOfflineFirst`) from [reader] and manage serdes generators
/// to and from a `RestProvider`.
class RestSerdes extends ProviderSerializable<RestSerializable> {
  /// Repository prefix passed to the generators. `Repository` will be appended and
  /// should not be included.
  final String repositoryName;

  RestSerdes(
    Element element,
    ConstantReader reader, {
    this.repositoryName,
  }) : super(element, reader, configKey: "restConfig");

  get config {
    if (reader.read(configKey).isNull) {
      return RestSerializable.defaults;
    }

    final fieldRenameObject = withinConfigKey("fieldRename")?.objectValue;
    final fieldRenameByEnumName = FieldRename.values.singleWhere(
      (f) => fieldRenameObject?.getField(f.toString().split('.')[1]) != null,
      orElse: () => null,
    );

    return RestSerializable(
      nullable: withinConfigKey("nullable")?.boolValue ?? RestSerializable.defaults.nullable,
      fieldRename: fieldRenameByEnumName ?? RestSerializable.defaults.fieldRename,
      endpoint: withinConfigKey("endpoint")?.stringValue ?? RestSerializable.defaults.endpoint,
      fromKey: withinConfigKey("fromKey")?.stringValue ?? RestSerializable.defaults.fromKey,
      toKey: withinConfigKey("toKey")?.stringValue ?? RestSerializable.defaults.toKey,
    );
  }

  get generators {
    final classElement = element as ClassElement;
    final fields = RestFields(classElement, config);
    return [
      RestDeserialize(classElement, fields, repositoryName: repositoryName),
      RestSerialize(classElement, fields, repositoryName: repositoryName),
    ];
  }
}
