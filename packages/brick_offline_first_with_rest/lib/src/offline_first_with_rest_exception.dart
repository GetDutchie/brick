import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart' show RestException;

class OfflineFirstWithRestException extends OfflineFirstException {
  OfflineFirstWithRestException(Exception originalError) : super(originalError);

  /// If [originalError] was produced by [RestProvider].
  bool get fromRest => originalError is RestException;

  int? get restErrorCode => fromRest ? (originalError as RestException).response.statusCode : null;

  /// Forward errors from a [RestException] response. `null` is returned
  /// if [originalError] was not [fromRest].
  Map<String, dynamic>? get restErrors {
    if (!fromRest) return null;

    return (originalError as RestException).errors;
  }
}
