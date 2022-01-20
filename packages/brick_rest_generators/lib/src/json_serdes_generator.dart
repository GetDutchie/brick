import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:brick_core/core.dart';

abstract class JsonSerdesGenerator<_Model extends Model,
        _Annotation extends FieldSerializable>
    extends SerdesGenerator<_Annotation, _Model> {
  @override
  final String providerName;

  @override
  final String repositoryName;

  JsonSerdesGenerator(
    ClassElement element,
    FieldsForClass<_Annotation> fields, {
    required this.repositoryName,
    required this.providerName,
  }) : super(element, fields);
}
