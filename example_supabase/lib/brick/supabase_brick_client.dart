import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// A HTTP Client that adds all necessary headers for requests to the
/// Supabase REST-API.
class SupabaseBrickClient extends http.BaseClient {
  SupabaseBrickClient({
    required this.supabaseAnonKey,
    http.Client? innerClient,
    this.resourceName = 'dart.http',
  }) : _innerClient = innerClient ?? http.Client();

  /// The anon key of the supabase project.
  ///
  /// This is sent in the request headers as the `apikey` field.
  final String supabaseAnonKey;

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
    final accessToken = Supabase.instance.client.auth.currentSession?.accessToken;

    request.headers.addAll({
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      'apikey': supabaseAnonKey,
      'Content-Type': 'application/json; charset=utf-8',
      // In order to use the upsert method for updates, the following header
      // is needed for the REST API to work correctly.
      // see // https://postgrest.org/en/v12/references/api/tables_views.html#upsert
      'Prefer': 'resolution=merge-duplicates',
    });

    return _innerClient.send(request);
  }

  @override
  void close() {
    _innerClient.close();
    super.close();
  }
}
