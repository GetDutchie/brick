import 'package:brick_rest/brick_rest.dart' show RestException;

class OfflineFirstException implements Exception {
  /// The producing error from either [RestProvider] or [SqliteProvider].
  final Exception originalError;

  OfflineFirstException(this.originalError);

  /// If [originalError] was produced by [RestProvider].
  bool get fromRest => originalError is RestException;

  String get message => originalError.toString();

  int? get restErrorCode => fromRest ? (originalError as RestException).response.statusCode : null;

  /// Forward errors from a [RestException] response. `null` is returned
  /// if [originalError] was not [fromRest].
  Map<String, dynamic>? get restErrors {
    if (!fromRest) return null;

    return (originalError as RestException).errors;
  }

  @override
  String toString() => message;
}
