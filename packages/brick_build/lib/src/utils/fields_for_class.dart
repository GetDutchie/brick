// Borrowed/inspired by [JsonSerializable](https://github.com/dart-lang/json_serializable/blob/3b3e25e7522ad71011aa23656b3cd66cdc8b860c/json_serializable/lib/src/field_helpers.dart)
import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/annotation_finder.dart';
import 'package:source_gen/source_gen.dart';

/// Checker for the field having a predetermined annotation
typedef HasFieldAnnotation = bool Function(FieldElement field);

/// Manages all fields of a [ClassElement]. Generously borrowed from JSON Serializable
abstract class FieldsForClass<_FieldAnnotation extends Object> {
  /// The annotated element
  final ClassElement element;

  /// The check for subannotations, e.g. [Sqlite]
  bool annotationCallback(FieldElement field) => finder.annotationForField(field) != null;

  /// Searches for annotations on fields
  AnnotationFinder<_FieldAnnotation> get finder;

  /// Returns the annotation for a given field
  _FieldAnnotation annotationForField(FieldElement element) => finder.annotationForField(element);

  /// Returns a [Set] of all instance [FieldElement] items for [element] and
  /// super classes, sorted first by their location in the inheritance hierarchy
  /// (super first) and then by their location in the source file.
  Iterable<FieldElement> get sorted {
    // Get all of the fields that need to be assigned
    final elementInstanceFields =
        Map.fromEntries(element.fields.where((e) => !e.isStatic).map((e) => MapEntry(e.name, e)));

    final inheritedFields = <String, FieldElement>{};

    // Get the list of all fields for `element`
    final allFields = elementInstanceFields.keys.toSet().union(inheritedFields.keys.toSet());

    final fields = allFields
        .map((e) => _FieldSet(elementInstanceFields[e]!, inheritedFields[e]!, annotationCallback))
        .toList();

    // Sort the fields using the `compare` implementation in _FieldSet
    fields.sort();

    return fields.map((fs) => fs.field).toList();
  }

  /// ignore private, `static`, and `Function` fields
  Iterable<FieldElement> get stableInstanceFields {
    return sorted.where((field) {
      return field.isPublic &&
          (field.isFinal || field.isConst || field.getter != null) &&
          !field.isStatic &&
          !field.type.isDartCoreFunction;
    });
  }

  FieldsForClass({required this.element});

  /// Returns `true` for `int get name => 5`
  static bool isComputedGetter(FieldElement field) {
    return !field.getter.runtimeType.toString().contains('ImplicitGetter');
  }
}

/// Ensures uniqueness of accessible fields within a [ClassElement]
class _FieldSet implements Comparable<_FieldSet> {
  final FieldElement field;
  final FieldElement sortField;
  final HasFieldAnnotation annotationCallback;

  _FieldSet._(this.field, this.sortField, this.annotationCallback)
      : assert(field.name == sortField.name);

  factory _FieldSet(
    FieldElement classField,
    FieldElement superField,
    HasFieldAnnotation annotationCallback,
  ) {
    // At least one of these will != null, perhaps both.
    final fields = [classField, superField].where((fe) => fe != null).toList();

    // Prefer the class field over the inherited field when sorting.
    final sortField = fields.first;

    // Prefer the field that's annotated with the desired annotation, if any.
    // If not, use the class field.
    final fieldHasAnnotation = fields.firstWhere(annotationCallback, orElse: () => fields.first);

    return _FieldSet._(fieldHasAnnotation, sortField, annotationCallback);
  }

  @override
  int compareTo(_FieldSet other) => _sortByLocation(sortField, other.sortField);

  static int _sortByLocation(FieldElement a, FieldElement b) {
    final checkerA = TypeChecker.fromStatic((a.enclosingElement as ClassElement).thisType);

    if (!checkerA.isExactly(b.enclosingElement)) {
      // in this case, you want to prioritize the enclosingElement that is more "super".
      if (checkerA.isAssignableFrom(b.enclosingElement)) {
        return -1;
      }

      final checkerB = TypeChecker.fromStatic((b.enclosingElement as ClassElement).thisType);

      if (checkerB.isAssignableFrom(a.enclosingElement)) {
        return 1;
      }
    }

    return _offsetFor(a).compareTo(_offsetFor(b));
  }

  /// Returns the offset of given field/property in its source file – with a
  /// preference for the getter if it's defined.
  static int _offsetFor(FieldElement e) {
    if (e.getter != null && e.getter!.nameOffset != e.nameOffset) {
      assert(e.nameOffset == -1);
      return e.getter!.nameOffset;
    }
    return e.nameOffset;
  }
}
