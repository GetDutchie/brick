import 'package:brick_rest/gzip_http_client.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:brick_rest/rest.dart';

import '__mocks__.dart' hide MockClient;

RestProvider withClient(MockClientHandler fn) {
  final client = GzipHttpClient(innerClient: MockClient(fn));
  return RestProvider(
    'http://localhost:3000',
    modelDictionary: restModelDictionary,
    client: client,
  );
}

void main() {
  group('GzipHttpClient', () {
    test('headers include Content-Encoding: gzip', () async {
      final provider = withClient((request) async {
        if (request.headers['Content-Encoding'] == 'gzip' &&
            request.headers['Accept-Encoding'] == 'gzip') {
          return http.Response('[{"name": "Guy"}]', 200);
        }

        return null;
      });
      final instance = DemoRestModel('Guy');
      final resp = await provider.upsert<DemoRestModel>(instance);
      expect(resp.statusCode, 200);
      expect(resp.body, '[{"name": "Guy"}]');
    });
  });
}
