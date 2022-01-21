import 'dart:convert';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
import 'package:brick_offline_first/src/offline_queue/rest_request_sqlite_cache_manager.dart';
import 'package:http/http.dart' as http;

class RestRequestSqliteCache extends RequestSqliteCache<http.Request> {
  RestRequestSqliteCache(http.Request request)
      : super(
            attemptColumn: HTTP_JOBS_ATTEMPTS_COLUMN,
            createdAtColumn: HTTP_JOBS_CREATED_AT_COLUMN,
            lockedColumn: HTTP_JOBS_LOCKED_COLUMN,
            primaryKeyColumn: HTTP_JOBS_PRIMARY_KEY_COLUMN,
            request: request,
            requestColumns: [
              HTTP_JOBS_BODY_COLUMN,
              HTTP_JOBS_ENCODING_COLUMN,
              HTTP_JOBS_REQUEST_METHOD_COLUMN,
              HTTP_JOBS_URL_COLUMN,
            ],
            tableName: HTTP_JOBS_TABLE_NAME,
            updateAtColumn: HTTP_JOBS_UPDATED_AT);

  bool get requestIsPush => ['POST', 'PUT', 'DELETE', 'PATCH'].contains(request.method);

  @override
  Map<String, dynamic> toSqlite() => {
        HTTP_JOBS_ATTEMPTS_COLUMN: 1,
        HTTP_JOBS_BODY_COLUMN: request.body,
        HTTP_JOBS_CREATED_AT_COLUMN: DateTime.now().millisecondsSinceEpoch,
        HTTP_JOBS_ENCODING_COLUMN: request.encoding.name,
        HTTP_JOBS_HEADERS_COLUMN: jsonEncode(request.headers),
        HTTP_JOBS_REQUEST_METHOD_COLUMN: request.method,
        HTTP_JOBS_UPDATED_AT: DateTime.now().millisecondsSinceEpoch,
        HTTP_JOBS_URL_COLUMN: request.url.toString(),
      };

  @override
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
}
