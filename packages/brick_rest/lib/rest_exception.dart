import 'dart:convert';

import 'package:brick_rest/src/rest_provider.dart';
import 'package:http/http.dart' as http;

/// An error class exclusive to the [RestProvider]
class RestException implements Exception {
  /// The HTTP response that triggered the exception
  final http.Response response;

  /// An error class exclusive to the [RestProvider]
  RestException(this.response);

  /// Decoded error messages if included under the top-level key 'errors' in the response.
  /// For example, `{"phone": ["Phone required"]}` in `{"errors":{"phone": ["Phone required"]}}`.
  Map<String, dynamic>? get errors {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('errors')) {
        return decoded['errors'];
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// A string representation of the exception
  String get message =>
      'statusCode=${response.statusCode} url=${response.request?.url} method=${response.request?.method} body=${response.body}';

  @override
  String toString() => message;
}
