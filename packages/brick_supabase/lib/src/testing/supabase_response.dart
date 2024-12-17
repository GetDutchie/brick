import 'package:brick_supabase/src/testing/supabase_mock_server.dart';

/// A simulated response from Supabase. This class is designed to DRY responses
/// when used with the [SupabaseMockServer]. For example:
/// ```dart
/// final resp = SupabaseResponse([
///   await mock.serialize(MyModel(name: 'Demo 1', id: '1')),
///   await mock.serialize(MyModel(name: 'Demo 2', id: '2')),
/// ]);
/// ```
class SupabaseResponse {
  /// The payload that Supabase would have returned. This can be a map or a list of decoded JSON objects
  final dynamic data;

  /// All recursively-discovered [realtimeSubsequentReplies]
  List<SupabaseResponse> get flattenedResponses =>
      realtimeSubsequentReplies.fold(<SupabaseResponse>[this], (acc, r) {
        void recurse(SupabaseResponse response) {
          acc.add(response);
          if (response.realtimeSubsequentReplies.isNotEmpty) {
            acc.addAll(response.realtimeSubsequentReplies);
            response.realtimeSubsequentReplies.forEach(recurse);
          }
        }

        recurse(r);
        return acc;
      });

  /// Additional headers that should be included in the response.
  /// Supabase's client sometimes requires header values to properly parse the result
  /// such as `{'content-range': '*/1'}`
  final Map<String, String>? headers;

  /// Additional replies sent after this instance's [data].
  /// Replies will be staggered by [realtimeSubsequentReplyDelay].
  ///
  /// While [flattenedResponses] supports recursion, it should never be
  /// necessary to have deeply nested responses.
  final List<SupabaseResponse> realtimeSubsequentReplies;

  /// Amount of time to delay each [realtimeSubsequentReplies]
  final Duration realtimeSubsequentReplyDelay;

  /// A simulated response from Supabase. This class is designed to DRY responses
  /// when used with the [SupabaseMockServer]. For example:
  /// ```dart
  /// final resp = SupabaseResponse([
  ///   await mock.serialize(MyModel(name: 'Demo 1', id: '1')),
  ///   await mock.serialize(MyModel(name: 'Demo 2', id: '2')),
  /// ]);
  /// ```
  const SupabaseResponse(
    this.data, {
    this.headers,
    this.realtimeSubsequentReplies = const [],
    this.realtimeSubsequentReplyDelay = const Duration(milliseconds: 30),
  });
}
