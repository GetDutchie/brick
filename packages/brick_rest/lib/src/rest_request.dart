/// A cohesive definition for `RestRequestTransformer`'s instance fields.
class RestRequest {
  /// HTTP headers
  final Map<String, String>? headers;

  /// The [HTTP method](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
  /// for the request. `DELETE`, `GET`, `PATCH`, `POST`, and `PUT` are supported.
  final String? method;

  /// This map is merged at the same level as the [topLevelKey] in the payload. For example,
  /// given `supplementalTopLevelData: {'other_key': true}`, the payload would become
  /// `{"topLevelKey": ..., "other_key": true}`. It is **strongly recommended** to avoid using
  /// this property. Your data should be managed at the model level, not the query level.
  final Map<String, dynamic>? supplementalTopLevelData;

  /// When serializing to REST, the payload may need to be nested within a top level key.
  /// Similarly, when deserializing to REST, the response may be nested within a top level key.
  /// If no key is defined, the first value will be returned during deserialization.
  ///
  /// This configuration is overriden when a query specifies `providerArgs['topLevelKey']`.
  ///
  /// **Example**
  /// Given the payload:
  /// ```dart
  /// { "user" : {"id" : 1, "name" : "Thomas" }}
  /// ```
  /// The [topLevelKey] would be `"user"`.
  final String? topLevelKey;

  /// The URL of the endpoint to invoke. This is **appended** to `baseEndpoint`.
  /// **Example**:
  /// ```dart
  /// if (query.limit == 1) {
  ///   return "/person/${query.providerArgs['id']}";
  /// }
  ///
  /// return "/people";
  /// ```
  final String? url;

  /// A cohesive definition for `RestRequestTransformer`'s instance fields.
  const RestRequest({
    this.headers,
    this.method,
    this.supplementalTopLevelData,
    this.topLevelKey,
    this.url,
  });

  /// Deserialize a request from JSON
  factory RestRequest.fromJson(Map<String, dynamic> data) => RestRequest(
        headers: data['headers'],
        method: data['method'],
        supplementalTopLevelData: data['supplementalTopLevelData'],
        topLevelKey: data['topLevelKey'],
        url: data['url'],
      );

  /// Copy a request with overriden parameters
  RestRequest copyWith({
    Map<String, String>? headers,
    String? method,
    Map<String, dynamic>? supplementalTopLevelData,
    String? topLevelKey,
    String? url,
  }) =>
      RestRequest(
        headers: headers ?? this.headers,
        method: method ?? this.method,
        supplementalTopLevelData: supplementalTopLevelData ?? this.supplementalTopLevelData,
        topLevelKey: topLevelKey ?? this.topLevelKey,
        url: url ?? this.url,
      );

  /// Serialize a request to JSON
  Map<String, dynamic> toJson() => {
        'headers': headers,
        'method': method,
        'supplementalTopLevelData': supplementalTopLevelData,
        'topLevelKey': topLevelKey,
        'url': url,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestRequest &&
          runtimeType == other.runtimeType &&
          headers == other.headers &&
          method == other.method &&
          supplementalTopLevelData == other.supplementalTopLevelData &&
          topLevelKey == other.topLevelKey &&
          url == other.url;

  @override
  int get hashCode =>
      headers.hashCode ^
      method.hashCode ^
      supplementalTopLevelData.hashCode ^
      topLevelKey.hashCode ^
      url.hashCode;
}
