import 'package:brick_core/core.dart';
import 'package:brick_rest/src/rest_request_transformer.dart';
import 'package:brick_rest/src/rest_provider.dart';
import 'package:brick_rest/src/rest_model.dart';

class _DefaultRestTransformer extends RestRequestTransformer {
  const _DefaultRestTransformer(Query? query, RestModel? instance) : super(null, null);
}

/// Constructors that convert app models to and from REST
abstract class RestAdapter<_Model extends RestModel> implements Adapter<_Model> {
  Future<_Model> fromRest(
    Map<String, dynamic> input, {
    required RestProvider provider,
    ModelRepository<RestModel>? repository,
  });

  /// The endpoint path to access provided a query. Must include a leading slash.
  RestRequestTransformer Function(Query?, _Model?)? get restRequest => _DefaultRestTransformer.new;

  Future<Map<String, dynamic>> toRest(
    _Model input, {
    required RestProvider provider,
    ModelRepository<RestModel>? repository,
  });

  /// Returns an enum value based on its string name. For example, given `'POST'`,
  /// and the enum `enum Methods { GET, POST, DELETE }`, `Methods.POST` is returned.
  static T? enumValueFromName<T>(Iterable<T> enumValues, String enumName) {
    return firstWhereOrNull(enumValues, (e) => e.toString().split('.').last == enumName);
  }

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
}
