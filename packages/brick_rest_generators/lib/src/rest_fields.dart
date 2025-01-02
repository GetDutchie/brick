// Generously inspired by JsonSerializable

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_rest/brick_rest.dart' show Rest, RestSerializable;
import 'package:brick_rest_generators/src/rest_serializable_extended.dart';

/// Find `@Rest` given a field
class RestAnnotationFinder extends AnnotationFinder<Rest>
    with AnnotationFinderWithFieldRename<Rest> {
  ///
  final RestSerializable? config;

  /// Find `@Rest` given a field
  RestAnnotationFinder([this.config]);

  @override
  Rest from(FieldElement element) {
    final obj = objectForField(element);

    if (obj == null) {
      return Rest(
        ignore: Rest.defaults.ignore,
        ignoreFrom: Rest.defaults.ignoreFrom,
        ignoreTo: Rest.defaults.ignoreTo,
        name: renameField(
          element.name,
          config?.fieldRename,
          RestSerializable.defaults.fieldRename,
        ),
        enumAsString: Rest.defaults.enumAsString,
      );
    }

    return Rest(
      defaultValue: obj.getField('defaultValue')!.toStringValue(),
      enumAsString: obj.getField('enumAsString')!.toBoolValue() ?? Rest.defaults.enumAsString,
      fromGenerator: obj.getField('fromGenerator')!.toStringValue(),
      ignore: obj.getField('ignore')!.toBoolValue() ?? Rest.defaults.ignore,
      ignoreFrom: obj.getField('ignoreFrom')!.toBoolValue() ?? Rest.defaults.ignoreFrom,
      ignoreTo: obj.getField('ignoreTo')!.toBoolValue() ?? Rest.defaults.ignoreTo,
      name: obj.getField('name')!.toStringValue() ??
          renameField(element.name, config?.fieldRename, RestSerializable.defaults.fieldRename),
      toGenerator: obj.getField('toGenerator')!.toStringValue(),
    );
  }
}

/// Converts all fields to [Rest]s for later consumption
class RestFields extends FieldsForClass<Rest> {
  @override
  final RestAnnotationFinder finder;

  ///
  final RestSerializableExtended? config;

  /// Converts all fields to [Rest]s for later consumption
  RestFields(ClassElement element, [this.config])
      : finder = RestAnnotationFinder(config),
        super(element: element);
}
