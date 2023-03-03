import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:brick_core/core.dart';

abstract class JsonSerdesGenerator<_Model extends Model, Annotation extends FieldSerializable>
    extends SerdesGenerator<Annotation, _Model> {
  @override
  final String providerName;

  @override
  final String repositoryName;

  JsonSerdesGenerator(
    ClassElement element,
    FieldsForClass<Annotation> fields, {
    required this.repositoryName,
    required this.providerName,
  }) : super(element, fields);
}
