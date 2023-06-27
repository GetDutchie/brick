import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart' show AnnotationFinder, FieldsForClass;
import 'package:brick_offline_first/brick_offline_first.dart';

/// Convert `@OfflineFirst` annotations into digestible code
class _OfflineFirstSerdesFinder extends AnnotationFinder<OfflineFirst> {
  _OfflineFirstSerdesFinder();

  @override
  OfflineFirst from(element) {
    final obj = objectForField(element);

    if (obj == null) return const OfflineFirst();

    final where = obj
        .getField('where')
        ?.toMapValue()
        ?.map((key, value) => MapEntry(key!.toStringValue()!, value!.toStringValue()!));

    return OfflineFirst(
      applyToRemoteDeserialization: obj.getField('applyToRemoteDeserialization')?.toBoolValue() ??
          OfflineFirst.defaults.applyToRemoteDeserialization,
      where: where,
    );
  }
}

/// Discover all fields with `@OfflineFirst`
class OfflineFirstFields extends FieldsForClass<OfflineFirst> {
  @override
  final finder = _OfflineFirstSerdesFinder();

  OfflineFirstFields(ClassElement element) : super(element: element);
}
