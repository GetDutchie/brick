// Generously inspired by JsonSerializable

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_rest/rest.dart' show Rest, RestSerializable, FieldRename;
import 'package:brick_build/src/annotation_finder.dart';
import 'package:brick_build/src/utils/fields_for_class.dart';
import 'package:brick_build/src/utils/string_helpers.dart';

/// Find `@Rest` given a field
class RestAnnotationFinder extends AnnotationFinder<Rest> {
  final RestSerializable config;

  RestAnnotationFinder([this.config]);

  /// Change serialization key based on the configuration.
  /// `name` defined with a field annotation (`@Rest`) take precedence.
  String _renameField(String name) {
    final renameTo = config?.fieldRename ?? RestSerializable.defaults.fieldRename;
    switch (renameTo) {
      case FieldRename.none:
        return name;
      case FieldRename.snake:
        return StringHelpers.snakeCase(name);
      case FieldRename.kebab:
        return StringHelpers.kebabCase(name);
      case FieldRename.pascal:
        return StringHelpers.pascalCase(name);
      default:
        throw FallThroughError();
    }
  }

  from(element) {
    final obj = objectForField(element);

    if (obj == null) {
      return Rest(
        ignore: Rest.defaults.ignore,
        ignoreFrom: Rest.defaults.ignoreFrom,
        ignoreTo: Rest.defaults.ignoreTo,
        name: _renameField(element.name),
        nullable: config?.nullable ?? Rest.defaults.nullable,
        enumAsString: Rest.defaults.enumAsString,
      );
    }

    return Rest(
      defaultValue: valueForDynamicField('defaultValue', element),
      enumAsString: obj.getField('enumAsString').toBoolValue() ?? Rest.defaults.enumAsString,
      fromGenerator: obj.getField('fromGenerator').toStringValue(),
      ignore: obj.getField('ignore').toBoolValue() ?? Rest.defaults.ignore,
      ignoreFrom: obj.getField('ignoreFrom').toBoolValue() ?? Rest.defaults.ignoreFrom,
      ignoreTo: obj.getField('ignoreTo').toBoolValue() ?? Rest.defaults.ignoreTo,
      name: obj.getField('name').toStringValue() ?? _renameField(element.name),
      nullable:
          obj.getField('nullable').toBoolValue() ?? config?.nullable ?? Rest.defaults.nullable,
      toGenerator: obj.getField('toGenerator').toStringValue(),
    );
  }
}

/// Converts all fields to [Rest]s for later consumption
class RestFields extends FieldsForClass<Rest> {
  final RestAnnotationFinder finder;
  final RestSerializable config;

  RestFields(ClassElement element, [RestSerializable this.config])
      : finder = RestAnnotationFinder(config),
        super(element: element);
}
