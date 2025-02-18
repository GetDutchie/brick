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
  group('RestProvider', () {
    group('#get', () {
      test('simple', () async {
        final provider = generateProvider('[{"name": "Thomas"}]');

        final instance = await provider.get<DemoRestModel>();
        expect(instance.first.name, 'Thomas');
      });

      test('without specifying a top level key', () async {
        final provider = generateProvider('{"people": [{"name": "Thomas"}]}');
        final instance = await provider.get<DemoRestModel>();
        expect(instance.first.name, 'Thomas');
      });
    });

    test('#defaultHeaders', () async {
      final headers = {'Authorization': 'token=12345'};
      final provider = generateProvider('[{"name": "Guy"}]')..defaultHeaders = headers;
      final instance = await provider.get<DemoRestModel>();
      expect(instance.first.name, 'Guy');
    });

    group('#upsert', () {
      test('basic', () async {
        final provider = generateProvider('{"name": "Guy"}', requestMethod: 'POST');

        final instance = DemoRestModel('Guy');
        final resp = await provider.upsert<DemoRestModel>(instance);
        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Guy"}');
      });

      test('RestProviderQuery#request#headers', () async {
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

      test('RestProviderQuery#request#method PUT', () async {
        final provider = generateProvider('{"name": "Guy"}', requestMethod: 'PUT');

        final instance = DemoRestModel('Guy');
        const query = Query(
          forProviders: [
            RestProviderQuery(
              request: RestRequest(method: 'PUT', url: '/'),
            ),
          ],
        );
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Guy"}');
      });

      test('RestProviderQuery#request#method PATCH', () async {
        final provider = generateProvider('{"name": "Guy"}', requestMethod: 'PATCH');

        final instance = DemoRestModel('Guy');
        const query = Query(
          forProviders: [
            RestProviderQuery(
              request: RestRequest(method: 'PATCH', url: '/'),
            ),
          ],
        );
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Guy"}');
      });

      test('RestProviderQuery#request#topLevelKey', () async {
        final provider = generateProvider(
          '{"name": "Thomas"}',
          requestMethod: 'POST',
          requestBody: '{"top":{"name":"Guy"}}',
        );

        final instance = DemoRestModel('Guy');
        const query = Query(
          forProviders: [
            RestProviderQuery(
              request: RestRequest(topLevelKey: 'top', url: '/'),
            ),
          ],
        );
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Thomas"}');
      });

      group('RestProviderQuery#request#supplementalTopLevelData', () {
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

    test('#delete', () async {
      final provider = generateProvider('{"name": "Thomas"}', requestMethod: 'DELETE');

      final instance = DemoRestModel('Guy');
      await provider.delete<DemoRestModel>(instance);
    });

    test('#statusCodeIsSuccessful', () {
      expect(RestProvider.statusCodeIsSuccessful(200), isTrue);
      expect(RestProvider.statusCodeIsSuccessful(201), isTrue);
      expect(RestProvider.statusCodeIsSuccessful(202), isTrue);
      expect(RestProvider.statusCodeIsSuccessful(204), isTrue);
      expect(RestProvider.statusCodeIsSuccessful(422), isFalse);
      expect(RestProvider.statusCodeIsSuccessful(500), isFalse);
    });
  });

  group('RestAdapter', () {
    final provider = generateProvider('');

    test('#toRest', () async {
      final instance = DemoRestModel('Thomas');
      final payload = await DemoRestModelAdapter().toRest(instance, provider: provider);
      expect(payload, containsPair('name', 'Thomas'));
    });

    test('#fromRest', () async {
      final instance = DemoRestModel('Thomas');
      final payload = await DemoRestModelAdapter().toRest(instance, provider: provider);
      final newModel = await DemoRestModelAdapter().fromRest(payload, provider: provider);
      expect(newModel.name, 'Thomas');
    });
  });
}
