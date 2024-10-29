class SupabaseResponse {
  final dynamic data;

  /// All recursively-discovered [realtimeSubsequentReplies]
  List<SupabaseResponse> get flattenedResponses {
    return realtimeSubsequentReplies.fold(<SupabaseResponse>[this], (acc, r) {
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
  }

  final Map<String, String>? headers;

  /// Additional replies sent after this instance's [data].
  /// Replies will be staggered by [realtimeSubsequentReplyDelay].
  ///
  /// While [flattenedResponses] supports recursion, it should never be
  /// necessary to have deeply nested responses.
  final List<SupabaseResponse> realtimeSubsequentReplies;

  /// Amount of time to delay each [realtimeSubsequentReplies]
  final Duration realtimeSubsequentReplyDelay;

  SupabaseResponse(
    this.data, {
    this.headers,
    this.realtimeSubsequentReplies = const [],
    this.realtimeSubsequentReplyDelay = const Duration(milliseconds: 10),
  });
}
