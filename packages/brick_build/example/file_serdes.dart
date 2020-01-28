import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import '../lib/generators.dart';
import 'file_fields.dart';
import 'file_deserialize.dart';
import 'file_serialize.dart';

/// In a real-world scenario, this would be a class containing model-level config information
class FileSerializable {
  const FileSerializable();
  static const defaults = FileSerializable();
}

/// This class would be invoked and created for a build step or function
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
