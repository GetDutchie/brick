import 'package:brick_core/core.dart';
import 'package:brick_rest/src/rest_request.dart';

/// Specify request formatting (such as `method` or `url`) for each Brick operation.
///
/// This class should be subclassed for each model. For example:
///
/// ```dart
/// @RestSerializable(
///   requestTransformer: MyModelOperationTransformer.new,
/// )
/// class MyModel extends RestModel {}
/// class MyModelOperationTransformer extends RestRequestTransformer<MyModel> {
///   final get = RestRequest(
///     url: 'https://myapi.com/mymodel'
///   );
/// }
/// ```
abstract class RestRequestTransformer {
  /// The operation used for any destructive data operations.
  RestRequest? get delete => null;

  /// The operation used for any single-fetch data operations for index
  /// or collection instances. `RestProvider#exists` also uses this property.
  RestRequest? get get => null;

  /// The model being sent to the REST API; this will
  /// only be non-null for [upsert] and [delete] operations.
  final Model? instance;

  /// A query provided with the provider or repository request.
  final Query? query;

  /// The operation used for any inserting or updating data operations.
  RestRequest? get upsert => null;

  /// Specify request formatting (such as `method` or `url`) for each Brick operation.
  ///
  /// This class should be subclassed for each model. For example:
  ///
  /// ```dart
  /// @RestSerializable(
  ///   requestTransformer: MyModelOperationTransformer.new,
  /// )
  /// class MyModel extends RestModel {}
  /// class MyModelOperationTransformer extends RestRequestTransformer<MyModel> {
  ///   final get = RestRequest(
  ///     url: 'https://myapi.com/mymodel'
  ///   );
  /// }
  /// ```
  const RestRequestTransformer(this.query, this.instance);
}
