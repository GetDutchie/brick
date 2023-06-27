import 'package:brick_rest/brick_rest.dart';
import 'package:brick_rest/gzip_http_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

RestProvider generateProvider(MockClientHandler fn) {
  final client = GZipHttpClient(innerClient: MockClient(fn));
  return RestProvider(
    'http://0.0.0.0:3000',
    modelDictionary: restModelDictionary,
    client: client,
  );
}

void main() {
  group('GZipHttpClient', () {
    test('headers include Content-Encoding: gzip', () async {
      final provider = generateProvider((request) async {
        if (request.headers['Content-Encoding'] == 'gzip') {
          return http.Response('[{"name": "Guy"}]', 200);
        }

        return http.Response('', 404);
      });
      final instance = DemoRestModel('Guy');
      final resp = await provider.upsert<DemoRestModel>(instance);
      expect(resp!.statusCode, 200);
      expect(resp.body, '[{"name": "Guy"}]');
    });
  });
}
