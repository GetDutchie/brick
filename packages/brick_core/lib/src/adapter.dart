import 'package:brick_core/src/model.dart';

/// An adapter is a factory that produces an app model. In an effort to normalize data input and
/// output between [Provider]s, subclasses must pass the data in `Map<String, dynamic>` format.
abstract class Adapter<_Model extends Model> {
  const Adapter();

  /// After Dart 2.12, `firstWhere` can be a non-nullable return value. Instead of an extension,
  /// a predictable static method is used instead.
  ///
  /// From https://github.com/dart-lang/collection/blob/master/lib/src/iterable_extensions.dart
  /// to avoid importing a package for a single function.
  static T? firstWhereOrNull<T>(Iterable<T> values, bool Function(T item) test) {
    for (var item in values) {
      if (test(item)) return item;
    }
    return null;
  }

  /// Returns an enum value based on its string name. For example, given `'POST'`,
  /// and the enum `enum Methods { GET, POST, DELETE }`, `Methods.POST` is returned.
  static T? enumValueFromName<T>(Iterable<T> enumValues, String enumName) {
    return firstWhereOrNull(enumValues, (e) => e.toString().split('.').last == enumName);
  }
}
