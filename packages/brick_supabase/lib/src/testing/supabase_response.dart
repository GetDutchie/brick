import 'package:supabase/supabase.dart';

class SupabaseResponse {
  final dynamic data;

  final Map<String, String>? headers;

  final Duration realtimeDelayBetweenResponses;

  final PostgresChangeEvent? realtimeEvent;

  final List<SupabaseResponse> realtimeResponses;

  List<SupabaseResponse> get flattenedResponses {
    return realtimeResponses.fold(<SupabaseResponse>[this], (acc, r) {
      void recurse(SupabaseResponse response) {
        if (response.realtimeResponses.isNotEmpty) {
          acc.addAll(response.realtimeResponses);
          response.realtimeResponses.forEach(recurse);
        }
      }

      recurse(r);
      return acc;
    });
  }

  SupabaseResponse(
    this.data, {
    this.headers,
    this.realtimeEvent,
    this.realtimeDelayBetweenResponses = const Duration(milliseconds: 10),
    this.realtimeResponses = const [],
  });
}
