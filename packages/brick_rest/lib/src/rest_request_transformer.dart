import 'package:brick_core/query.dart';
import 'package:brick_rest/src/rest_model.dart';

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
///   final get = const RestRequest(
///     url: 'https://myapi.com/mymodel'
///   );
/// }
/// ```
abstract class RestRequestTransformer<TModel extends RestModel> {
  /// The operation used for any destructive data operations.
  RestRequest? get delete => null;

  /// The operation used for any single-fetch data operations for index
  /// or collection instances. `RestProvider#exists` also uses this property.
  RestRequest? get get => null;

  /// The model being sent to the REST API; this will
  /// only be non-null for [upsert] and [delete] operations.
  final TModel? instance;

  /// A query provided with the provider or repository request.
  final Query? query;

  /// The operation used for any inserting or updating data operations.
  RestRequest? get upsert => null;

  const RestRequestTransformer(this.query, this.instance);
}

/// A cohesive definition for [RestRequestTransformer]'s instance fields.
class RestRequest {
  final Map<String, String>? headers;

  /// The [HTTP method](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
  /// for the request. `DELETE`, `GET`, `PATCH`, `POST`, and `PUT` are supported.
  final String? method;

  /// When serializing to REST, the payload may need to be nested within a top level key.
  /// Similarly, when deserializing to REST, the response may be nested within a top level key.
  /// If no key is defined, the first value will be returned during deserialization.
  ///
  /// This configuration is overriden when a query specifies `providerArgs['topLevelKey']`.
  ///
  /// **Example**
  /// Given the payload:
  /// ```
  /// { "user" : {"id" : 1, "name" : "Thomas" }}
  /// ```
  /// The [topLevelKey] would be `"user"`.
  final String? topLevelKey;

  /// The URL of the endpoint to invoke. This is **appended** to `baseEndpoint`.
  /// **Example**:
  /// ```dart
  /// if (query.providerArgs['limit'] == 1) {
  ///   return "/person/${query.providerArgs['id']}";
  /// }
  ///
  /// return "/people";
  /// ```
  final String? url;

  const RestRequest({
    this.headers,
    this.method,
    this.topLevelKey,
    this.url,
  });

  factory RestRequest.fromJson(Map<String, dynamic> data) {
    return RestRequest(
      headers: data['headers'],
      method: data['method'],
      topLevelKey: data['topLevelKey'],
      url: data['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headers': headers,
      'method': method,
      'topLevelKey': topLevelKey,
      'url': url,
    };
  }
}
