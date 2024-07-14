import 'package:brick_supabase/env.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// A HTTP Client that adds the supabase api key and the access token of the
/// current supabase auth session to the request headers.
class JWTClient extends http.BaseClient {
  JWTClient({
    http.Client? innerClient,
    this.resourceName = 'dart.http',
  }) : _innerClient = innerClient ?? http.Client();

  /// Populates APM's "RESOURCE" column. Defaults to `dart.http`.
  final String resourceName;

  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  ///
  /// By default, a new [http.Client] will be instantiated and used.
  final http.Client _innerClient;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // The access token is automatically refreshed by the supabase client
    final accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;

    request.headers.addAll({
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      'apikey': SUPABASE_ANON_KEY,
    });

    return _innerClient.send(request);
  }

  @override
  void close() {
    _innerClient.close();
    super.close();
  }
}
