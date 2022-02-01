import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

MockClient stubResult({String response = 'response', int? statusCode}) {
  return MockClient((req) async {
    return http.Response(response, statusCode ?? 200, request: req);
  });
}
