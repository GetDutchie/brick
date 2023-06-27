import 'package:brick_build/generators.dart';
import 'package:brick_core/core.dart';
import 'package:brick_core/field_serializable.dart';

abstract class JsonSerdesGenerator<_Model extends Model, Annotation extends FieldSerializable>
    extends SerdesGenerator<Annotation, _Model> {
  @override
  final String providerName;

  @override
  final String repositoryName;

  JsonSerdesGenerator(
    super.element,
    super.fields, {
    required this.repositoryName,
    required this.providerName,
  });
}
