import 'package:brick_build/src/annotation_finder.dart';
import 'package:brick_build/src/utils/string_helpers.dart';
import 'package:brick_core/field_rename.dart';

/// Rename the field name to the value of [FieldRename]
mixin AnnotationFinderWithFieldRename<Annotation extends Object> on AnnotationFinder<Annotation> {
  /// Change serialization key based on the configuration.
  /// `name` defined with a field annotation takes precedence.
  String renameField(String name, FieldRename? configValue, FieldRename defaultValue) {
    final renameTo = configValue ?? defaultValue;
    switch (renameTo) {
      case FieldRename.none:
        return name;
      case FieldRename.snake:
        return StringHelpers.snakeCase(name);

      /// Converts a camelized string to kebab-case
      /// Taken from [json_serializable](https://github.com/dart-lang/json_serializable/blob/d7e6612cf947e150710007a63b439f8f0c316d42/json_serializable/lib/src/utils.dart#L38-L47)
      case FieldRename.kebab:
        return name.replaceAllMapped(RegExp('[A-Z]'), (match) {
          var lower = match.group(0)!.toLowerCase();

          if (match.start > 0) {
            lower = '-$lower';
          }

          return lower;
        });

      /// Capitalizes first letter
      /// Taken from [json_serializable](https://github.com/dart-lang/json_serializable/blob/d7e6612cf947e150710007a63b439f8f0c316d42/json_serializable/lib/src/utils.dart#L30-L36)
      case FieldRename.pascal:
        if (name.isEmpty) return '';

        return name[0].toUpperCase() + name.substring(1);
    }
  }
}
