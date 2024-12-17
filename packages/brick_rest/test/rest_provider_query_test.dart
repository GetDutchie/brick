import 'package:brick_core/core.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

RestProvider generateProvider(String response, {String? requestBody, String? requestMethod}) =>
    RestProvider(
      'http://0.0.0.0:3000',
      modelDictionary: restModelDictionary,
      client: generateClient(response, requestBody: requestBody, requestMethod: requestMethod),
    );

void main() {
  group('RestProviderQuery', () {
    test('#headers', () async {
      final provider = RestProvider(
        'http://0.0.0.0:3000',
        modelDictionary: restModelDictionary,
        client: MockClient((req) async {
          if (req.method == 'POST' && req.headers['Authorization'] == 'Basic xyz') {
            return http.Response('{"name": "Thomas"}', 200);
          }

          throw StateError('No response');
        }),
      );

      final instance = DemoRestModel('Guy');
      const query = Query(
        forProviders: [
          RestProviderQuery(
            request: RestRequest(headers: {'Authorization': 'Basic xyz'}, url: '/'),
          ),
        ],
      );
      final resp = await provider.upsert<DemoRestModel>(instance, query: query);

      expect(resp!.statusCode, 200);
      expect(resp.body, '{"name": "Thomas"}');
    });

    test('#method PUT', () async {
      final provider = generateProvider('{"name": "Guy"}', requestMethod: 'PUT');

      final instance = DemoRestModel('Guy');
      const query =
          Query(forProviders: [RestProviderQuery(request: RestRequest(method: 'PUT', url: '/'))]);
      final resp = await provider.upsert<DemoRestModel>(instance, query: query);

      expect(resp!.statusCode, 200);
      expect(resp.body, '{"name": "Guy"}');
    });

    test('#method PATCH', () async {
      final provider = generateProvider('{"name": "Guy"}', requestMethod: 'PATCH');

      final instance = DemoRestModel('Guy');
      const query = Query(
        forProviders: [RestProviderQuery(request: RestRequest(method: 'PATCH', url: '/'))],
      );
      final resp = await provider.upsert<DemoRestModel>(instance, query: query);

      expect(resp!.statusCode, 200);
      expect(resp.body, '{"name": "Guy"}');
    });

    test('#topLevelKey', () async {
      final provider = generateProvider(
        '{"name": "Thomas"}',
        requestMethod: 'POST',
        requestBody: '{"top":{"name":"Guy"}}',
      );

      final instance = DemoRestModel('Guy');
      const query = Query(
        forProviders: [RestProviderQuery(request: RestRequest(topLevelKey: 'top', url: '/'))],
      );
      final resp = await provider.upsert<DemoRestModel>(instance, query: query);

      expect(resp!.statusCode, 200);
      expect(resp.body, '{"name": "Thomas"}');
    });

    group('#supplementalTopLevelData', () {
      test('#get', () async {
        final provider = generateProvider(
          '[{"name": "Thomas"}]',
          requestMethod: 'POST',
          requestBody: '{"other_name":{"first_name":"Thomas"}}',
        );

        const query = Query(
          forProviders: [
            RestProviderQuery(
              request: RestRequest(
                url: '/',
                method: 'POST',
                supplementalTopLevelData: {
                  'other_name': {'first_name': 'Thomas'},
                },
              ),
            ),
          ],
        );
        final instance = await provider.get<DemoRestModel>(query: query);

        expect(instance.first.name, 'Thomas');
      });

      test('#upsert', () async {
        final provider = generateProvider(
          '{"name": "Thomas"}',
          requestMethod: 'POST',
          requestBody: '{"top":{"name":"Guy"},"other_name":{"first_name":"Thomas"}}',
        );

        final instance = DemoRestModel('Guy');
        const query = Query(
          forProviders: [
            RestProviderQuery(
              request: RestRequest(
                topLevelKey: 'top',
                url: '/',
                supplementalTopLevelData: {
                  'other_name': {'first_name': 'Thomas'},
                },
              ),
            ),
          ],
        );
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Thomas"}');
      });
    });
  });
}
