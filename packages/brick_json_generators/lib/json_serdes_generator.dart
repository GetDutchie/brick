import 'package:brick_build/generators.dart';
import 'package:brick_core/core.dart';
import 'package:brick_core/field_serializable.dart';

/// Default generator implementation JSON-based providers
abstract class JsonSerdesGenerator<_Model extends Model, Annotation extends FieldSerializable>
    extends SerdesGenerator<Annotation, _Model> {
  @override
  final String providerName;

  @override
  final String repositoryName;

  /// Default generator implementation JSON-based providers
  JsonSerdesGenerator(
    super.element,
    super.fields, {
    required this.repositoryName,
    required this.providerName,
  });
}
