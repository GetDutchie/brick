import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';

MockClient stubResult({String response = 'response', int? statusCode}) {
  return MockClient((req) async {
    return http.Response(response, statusCode ?? 200, request: req);
  });
}

Stream<Response> stubGraphqResult(Map<String, dynamic> response, errors) {
  return Stream.fromIterable([
    Response(data: response, errors: errors),
  ]);
}

class MockLink extends Mock implements Link {
  @override
  Stream<Response> request(Request? request, [NextLink? forward]) => super.noSuchMethod(
        Invocation.method(#request, [request, forward]),
        returnValue: Stream.fromIterable(
          <Response>[],
        ),
      ) as Stream<Response>;
}
