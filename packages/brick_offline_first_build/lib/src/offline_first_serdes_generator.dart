import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:brick_offline_first_build/src/offline_first_checker.dart';
import 'package:brick_offline_first_build/src/offline_first_fields.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_build/src/utils/fields_for_class.dart';
import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:brick_sqlite_abstract/db.dart' show InsertForeignKey;

abstract class OfflineFirstSerdesGenerator<_FieldAnnotation extends FieldSerializable>
    extends SerdesGenerator<_FieldAnnotation, OfflineFirstChecker> {
  /// [FieldsForClass] for the `@OfflineFirst` annotation
  final OfflineFirstFields offlineFirstFields;

  @override
  final String repositoryName;

  static const REST_PROVIDER_NAME = 'Rest';
  static const SQLITE_PROVIDER_NAME = 'Sqlite';

  OfflineFirstSerdesGenerator(
    ClassElement element,
    FieldsForClass<_FieldAnnotation> _fields, {
    String repositoryName,
  })  : this.offlineFirstFields = OfflineFirstFields(element),
        this.repositoryName = repositoryName ?? 'OfflineFirst',
        super(element, _fields);

  @override
  String coderForField(
    FieldElement field,
    OfflineFirstChecker checker, {
    _FieldAnnotation fieldAnnotation,
    bool wrappedInFuture,
    OfflineFirst offlineFirstAnnotation,
  });

  @override
  String generateCoder(field, checker, {fieldAnnotation, wrappedInFuture}) {
    return coderForField(
      field,
      checker,
      fieldAnnotation: fieldAnnotation,
      wrappedInFuture: wrappedInFuture,
      offlineFirstAnnotation: offlineFirstFields.annotationForField(field),
    );
  }

  /// Return an `OfflineFirstChecker` for a field.
  /// If the field is a future type, returns a checker of the arg type.
  @override
  OfflineFirstChecker checkerForField(FieldElement field, {DartType type}) {
    final checker = OfflineFirstChecker(type ?? field.type);
    if (checker.isFuture) {
      return checkerForField(field, type: checker.argType);
    }

    return checker;
  }

  /// Generate foreign key column if the type is a sibling;
  /// otherwise, return the field's annotated name;
  @override
  String providerNameForField(annotatedName, {checker}) {
    if (checker.isSibling && providerName == SQLITE_PROVIDER_NAME) {
      return InsertForeignKey.foreignKeyColumnName(
          checker.unFuturedType.getDisplayString(), annotatedName);
    }

    return annotatedName;
  }
}
