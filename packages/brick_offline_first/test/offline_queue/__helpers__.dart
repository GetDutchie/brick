import 'dart:convert';

import 'package:brick_offline_first/src/offline_queue/rest_request_sqlite_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

MockClient stubResult({String response = 'response', int? statusCode}) {
  return MockClient((req) async {
    return http.Response(response, statusCode ?? 200, request: req);
  });
}

http.Request sqliteToRequest(Map<String, dynamic> data) {
  var _request = http.Request(
    data[HTTP_JOBS_REQUEST_METHOD_COLUMN],
    Uri.parse(data[HTTP_JOBS_URL_COLUMN]),
  );

  if (data[HTTP_JOBS_ENCODING_COLUMN] != null) {
    final encoding = Encoding.getByName(data[HTTP_JOBS_ENCODING_COLUMN]);
    if (encoding != null) _request.encoding = encoding;
  }

  if (data[HTTP_JOBS_HEADERS_COLUMN] != null) {
    _request.headers.addAll(Map<String, String>.from(jsonDecode(data[HTTP_JOBS_HEADERS_COLUMN])));
  }

  if (data[HTTP_JOBS_BODY_COLUMN] != null) {
    _request.body = data[HTTP_JOBS_BODY_COLUMN];
  }

  return _request;
}
