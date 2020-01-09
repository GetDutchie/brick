import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/offline_first/offline_first_checker.dart';
import 'package:brick_build/src/offline_first/offline_first_fields.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_build/src/utils/fields_for_class.dart';
import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_sqlite_abstract/db.dart' show InsertForeignKey;

abstract class OfflineFirstSerdesGenerator<_FieldAnnotation extends FieldSerializable>
    extends SerdesGenerator<_FieldAnnotation> {
  /// [FieldsForClass] for the `@OfflineFirst` annotation
  final OfflineFirstFields offlineFirstFields;

  final String repositoryName;

  String get constructorName => "from$providerName";

  String get serializeMethod => "to$providerName";

  /// All fields that are serializable by this generator and are not declared
  /// to be ignored by an annotation.
  Iterable<FieldElement> get unignoredFields {
    return fields.stableInstanceFields.where((field) {
      final annotation = fields.annotationForField(field);
      final checker = checkerForField(field);

      return !annotation.ignore && checker.isSerializable;
    });
  }

  static const REST_PROVIDER_NAME = "Rest";
  static const SQLITE_PROVIDER_NAME = "Sqlite";

  OfflineFirstSerdesGenerator(
    ClassElement element,
    FieldsForClass<_FieldAnnotation> _fields, {
    String repositoryName,
  })  : offlineFirstFields = OfflineFirstFields(element),
        repositoryName = repositoryName ?? "OfflineFirst",
        super(element, _fields);

  /// Produces serializing or deserializing method given a field type and [OfflineFirstChecker]
  ///
  /// To simplify checking, `Future`s are unwrapped before they get to this method.
  /// If the type was originally a future, `wrappedInFuture` is `true`.
  /// For example, `Future<List<int>>` will be an iterable according to the checker and
  /// `wrappedInFuture` will be `true`.
  String coderForField({
    OfflineFirstChecker checker,
    FieldElement field,
    _FieldAnnotation fieldAnnotation,
    OfflineFirst offlineFirstAnnotation,
    bool wrappedInFuture,
  });

  @override
  String addField(FieldElement field, _FieldAnnotation fieldAnnotation) {
    bool wrappedInFuture = false;
    final isComputedGetter = FieldsForClass.isComputedGetter(field);

    var checker = OfflineFirstChecker(field.type);
    if (checker.isFuture) {
      wrappedInFuture = true;
      checker = checkerForField(field, type: checker.argType);
    }

    if ((isComputedGetter && doesDeserialize) ||
        fieldAnnotation.ignore ||
        !checker.isSerializable) {
      return null;
    }

    if (wrappedInFuture && checker.isIterable && checker.isArgTypeAFuture) {
      throw InvalidGenerationSourceError(
        "Future iterable future types are not supported by Brick. Please revise to `Future<Iterable<Type>>` or `Iterable<Future<Type>>`.",
        todo: "Revise to `Future<Iterable<Type>>` or `Iterable<Future<Type>>`",
        element: field,
      );
    }

    final coder = coderForField(
      checker: checker,
      field: field,
      fieldAnnotation: fieldAnnotation,
      offlineFirstAnnotation: offlineFirstFields.annotationForField(field),
      wrappedInFuture: wrappedInFuture,
    );

    if (coder != null) {
      final name = serializedFieldName(checker, fieldAnnotation.name);
      final deserializerNullability =
          fieldAnnotation.nullable ? "data['$name'] == null ? null :" : '';
      final prefix = doesDeserialize ? "${field.name}: $deserializerNullability" : "'$name':";
      return "$prefix $coder";
    }

    return null;
  }

  /// Return an `OfflineFirstChecker` for a field.
  /// If the field is a future type, returns a checker of the arg type.
  OfflineFirstChecker checkerForField(FieldElement field, {DartType type}) {
    final checker = OfflineFirstChecker(type ?? field.type);
    if (checker.isFuture) {
      return checkerForField(field, type: checker.argType);
    }

    return checker;
  }

  String defaultValueSuffix(_FieldAnnotation fieldAnnotation) {
    return fieldAnnotation.defaultValue != null ? ' ?? ${fieldAnnotation.defaultValue}' : '';
  }

  /// Replace [OfflineFirst]'s provided placeholders
  String digestPlaceholders(String input, String annotatedName, String fieldName) {
    input = input
        .replaceAll(OfflineFirst.ANNOTATED_NAME_VARIABLE, annotatedName)
        .replaceAll(OfflineFirst.DATA_PROPERTY_VARIABLE, "data['$annotatedName']")
        .replaceAll(OfflineFirst.INSTANCE_PROPERTY_VARIABLE, "instance.$fieldName");
    return super.digestCustomGeneratorPlaceholders(input);
  }

  /// If this element possesses a factory such as `fromRest`
  bool hasConstructor(DartType type) {
    final classElement = type.element as ClassElement;
    return classElement.getNamedConstructor(constructorName) != null;
  }

  /// If this field possesses a serializing method such as `toSqlite`
  bool hasSerializer(DartType type) {
    final classElement = type.element as ClassElement;
    return classElement.getMethod(serializeMethod) != null;
  }

  /// Cast mapped values to their desired output value
  String iterableCast(
    DartType argType, {
    bool isSet = false,
    bool isList = false,
    bool isFuture = false,
  }) {
    if (isSet || isList) {
      final method = isSet ? 'Set' : 'List';
      final castType = isFuture ? "Future<$argType>" : argType;
      return "?.to$method()?.cast<$castType>()";
    }

    return "?.cast<$argType>()";
  }

  /// Generate foreign key column if the type is a sibling;
  /// otherwise, return the field's annotated name;
  String serializedFieldName(OfflineFirstChecker checker, String annotatedName) {
    if (checker.isSibling && providerName == SQLITE_PROVIDER_NAME) {
      return InsertForeignKey.foreignKeyColumnName(checker.unFuturedType.name, annotatedName);
    }

    return annotatedName;
  }
}
