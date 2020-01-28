import 'package:analyzer/dart/element/element.dart';
import '../lib/src/provider_serializable.dart';
import 'file_fields.dart';
import 'package:source_gen/source_gen.dart';

/// In a real-world scenario, this would be a class containing model-level config information
class FileSerializable {
  const FileSerializable();
  static const defaults = FileSerializable();
}

class FileSerdes extends ProviderSerializable<FileSerializable> {
  /// Repository prefix passed to the generators. `Repository` will be appended and
  /// should not be included.
  final String repositoryName;

  FileSerdes(
    Element element,
    ConstantReader reader, {
    this.repositoryName,
  }) : super(element, reader, configKey: 'fileConfig');

  @override
  get generators {
    final classElement = element as ClassElement;
    final fields = FileFields(classElement);
    return [
      FileDeserialize(classElement, fields, repositoryName: repositoryName),
      FileSerialize(classElement, fields, repositoryName: repositoryName),
    ];
  }
}
