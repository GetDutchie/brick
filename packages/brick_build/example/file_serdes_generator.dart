import 'package:analyzer/dart/element/element.dart';
import 'package:brick_core/core.dart' show Model;
import 'package:meta/meta.dart';
import '../lib/generators.dart';
import 'file_fields.dart';

/// This would be in a separate package
abstract class FileModel extends Model {}

abstract class FileSerdesGenerator<_Model extends FileModel> extends SerdesGenerator<File, _Model> {
  final String providerName = "File";

  final String repositoryName;

  FileSerdesGenerator(
    ClassElement element,
    FileFields fields, {
    @required this.repositoryName,
  }) : super(element, fields);
}
