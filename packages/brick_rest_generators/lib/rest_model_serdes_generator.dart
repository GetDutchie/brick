import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/field_rename.dart';
import 'package:brick_rest/brick_rest.dart' show RestSerializable;
import 'package:brick_rest_generators/src/rest_deserialize.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:brick_rest_generators/src/rest_serializable_extended.dart';
import 'package:brick_rest_generators/src/rest_serialize.dart';

/// Digest a `restConfig` (`@ConnectOfflineFirstWithRest`) from [reader] and manage serdes generators
/// to and from a `RestProvider`.
class RestModelSerdesGenerator extends ProviderSerializableGenerator<RestSerializable> {
  /// Repository prefix passed to the generators. `Repository` will be appended and
  /// should not be included.
  final String? repositoryName;

  /// Digest a `restConfig` (`@ConnectOfflineFirstWithRest`) from [reader] and manage serdes generators
  /// to and from a `RestProvider`.
  RestModelSerdesGenerator(
    super.element,
    super.reader, {
    this.repositoryName,
  }) : super(configKey: 'restConfig');

  @override
  RestSerializableExtended get config {
    if (reader.peek(configKey) == null) {
      return const RestSerializableExtended();
    }

    final fieldRenameIndex =
        withinConfigKey('fieldRename')?.objectValue.getField('index')?.toIntValue();
    final fieldRename = fieldRenameIndex != null ? FieldRename.values[fieldRenameIndex] : null;
    final function = withinConfigKey('requestTransformer')?.objectValue.toFunctionValue();
    var functionName = function?.enclosingElement3.name;
    if (function is ConstructorElement) {
      functionName = '$functionName.new';
    }

    return RestSerializableExtended(
      fieldRename: fieldRename ?? RestSerializable.defaults.fieldRename,
      nullable: withinConfigKey('nullable')?.boolValue ?? RestSerializable.defaults.nullable,
      requestName: functionName,
    );
  }

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = RestFields(classElement, config);
    return [
      RestDeserialize(classElement, fields, repositoryName: repositoryName!),
      RestSerialize(classElement, fields, repositoryName: repositoryName!),
    ];
  }
}
