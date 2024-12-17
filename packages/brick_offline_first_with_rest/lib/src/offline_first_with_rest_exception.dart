import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart' show RestException, RestProvider;

/// Forwarded exception thrown from a [RestException]. The implementation may choose
/// to ignore this exception if the latest REST data is not important.
class OfflineFirstWithRestException extends OfflineFirstException {
  /// Forwarded exception thrown from a [RestException]. The implementation may choose
  /// to ignore this exception if the latest REST data is not important.
  OfflineFirstWithRestException(super.originalError);

  /// If [originalError] was produced by [RestProvider].
  bool get fromRest => originalError is RestException;

  ///
  int? get restErrorCode => fromRest ? (originalError as RestException).response.statusCode : null;

  /// Forward errors from a [RestException] response. `null` is returned
  /// if [originalError] was not [fromRest].
  Map<String, dynamic>? get restErrors {
    if (!fromRest) return null;

    return (originalError as RestException).errors;
  }
}
