import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:meta/meta.dart' show protected;
import 'package:source_gen/source_gen.dart' show ConstantReader, InvalidGenerationSourceError;

/// Given an element and annotation, output a digestable config
abstract class ProviderSerializableGenerator<Config> {
  /// The annotated element
  final Element element;

  /// Property under the annotation that contains the serialized config.
  ///
  /// Such as `"restConfig"` here:
  /// ```dart
  /// @ConnectOfflineFirstWithRest(
  ///   restConfig: RestSerializable(...)
  /// )
  /// ```
  final String configKey;

  /// Deserialize a [Config] from an annotation, such as `RestSerializable`.
  Config? get config => null;

  /// Produce serializer and deserializer generators
  List<SerdesGenerator> get generators;

  /// The reader generated from the annotation
  final ConstantReader reader;

  /// Given an element and annotation, output a digestable config
  ProviderSerializableGenerator(
    this.element,
    this.reader, {
    required this.configKey,
  }) {
    /// Verify the annotated element is a [ClassElement], otherwise throw
    if (element is! ClassElement) {
      final name = element.name;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$name`.',
        todo: 'Please supply a proper class element instead of `$name`.',
        element: element,
      );
    }
  }

  /// `ConstantReader#read` does not return `null`, so we must safely navigate it
  @protected
  ConstantReader? withinConfigKey(String property) {
    if (reader.peek(configKey) == null) return null;

    final nestedConstant = reader.read(configKey).read(property);
    if (nestedConstant.isNull) return null;

    return nestedConstant;
  }
}
