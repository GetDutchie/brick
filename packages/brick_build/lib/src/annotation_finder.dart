// Generously inspired by JsonSerializable

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/utils/shared_checker.dart';
import 'package:source_gen/source_gen.dart';

/// Find an [Annotation] per field.
abstract class AnnotationFinder<Annotation extends Object> {
  final _columnChecker = TypeChecker.fromRuntime(Annotation);

  /// Holder of previously generated [Annotation]s
  final _columnExpando = Expando<Annotation>();

  /// Find an [Annotation] per field.
  AnnotationFinder();

  /// Given a field element, retrieve the [Annotation] equivalent
  Annotation annotationForField(FieldElement field) => _columnExpando[field] ??= from(field);

  /// Create a [Annotation] based on a [FieldElement]
  Annotation from(FieldElement element);

  /// Find annotation for [FieldElement] if one exists
  DartObject? objectForField(FieldElement field) {
    final firstOfType = _columnChecker.firstAnnotationOfExact(field);

    if (firstOfType != null) {
      return firstOfType;
    }

    if (field.getter == null) {
      return null;
    }

    return _columnChecker.firstAnnotationOfExact(field.getter!);
  }

  /// Return the actual value for fields of an element that could be one of any primitive
  dynamic valueForDynamicField(String fieldName, FieldElement element) {
    final dynamicValue = objectForField(element)?.getField(fieldName);
    if (dynamicValue == null || dynamicValue.isNull) {
      return null;
    }

    final checker = SharedChecker(dynamicValue.type!);
    if (checker.isEnum || !checker.isSerializable) {
      throw Exception('$fieldName on ${element.name} must be a primitive');
    }

    if (checker.isBool) return dynamicValue.toBoolValue();
    if (checker.isDouble) return dynamicValue.toDoubleValue();
    if (checker.isInt) return dynamicValue.toIntValue();
    if (checker.isString) return '"${dynamicValue.toStringValue()}"';
    if (checker.isList) return dynamicValue.toListValue();
    if (checker.isSet) return dynamicValue.toSetValue();
    if (checker.isMap) return dynamicValue.toMapValue();
  }
}
