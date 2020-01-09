import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:brick_core/core.dart';
import 'package:mockito/mockito.dart';

import 'package:brick_rest/rest.dart';
import '__mocks__.dart';

void main() {
  group("RestProvider", () {
    MockClient client;
    RestProvider provider;

    setUp(() {
      client = MockClient();
      provider = RestProvider(
        "http://localhost:3000",
        modelDictionary: restModelDictionary,
        client: client,
      );
    });

    group("#get", () {
      test("simple", () async {
        when(client.get('http://localhost:3000/person'))
            .thenAnswer((_) async => http.Response('[{"name": "Thomas"}]', 200));

        final m = await provider.get<DemoRestModel>();
        final testable = m.first;
        expect(testable.name, "Thomas");
      });

      test("without specifying a top level key", () async {
        when(client.get('http://localhost:3000/person'))
            .thenAnswer((_) async => http.Response('{"people": [{"name": "Thomas"}]}', 200));

        final m = await provider.get<DemoRestModel>();
        final testable = m.first;
        expect(testable.name, "Thomas");
      });
    });

    test("#defaultHeaders", () async {
      final headers = {'Authorization': 'token=12345'};

      when(client.get('http://localhost:3000/person'))
          .thenAnswer((_) async => http.Response('[{"name": "Thomas"}]', 200));
      when(client.get('http://localhost:3000/person', headers: headers))
          .thenAnswer((_) async => http.Response('[{"name": "Guy"}]', 200));

      provider.defaultHeaders = headers;
      final m = await provider.get<DemoRestModel>();
      final testable = m.first;
      expect(testable.name, "Guy");
    });

    group("#upsert", () {
      test("basic", () async {
        when(client.post(
          'http://localhost:3000/person',
          body: anyNamed("body"),
          headers: anyNamed("headers"),
          encoding: anyNamed("encoding"),
        )).thenAnswer((_) async => http.Response('{"name": "Guy"}', 200));

        final instance = DemoRestModel("Guy");
        final resp = await provider.upsert<DemoRestModel>(instance);
        expect(resp.statusCode, 200);
        expect(resp.body, '{"name": "Guy"}');
      });

      test("params['headers']", () async {
        when(client.post(
          'http://localhost:3000/person',
          body: anyNamed("body"),
          headers: {"Content-Type": "application/json", "Authorization": "Basic xyz"},
          encoding: anyNamed("encoding"),
        )).thenAnswer((_) async => http.Response('{"name": "Thomas"}', 200));

        final instance = DemoRestModel("Guy");
        final query = Query(params: {
          'headers': {'Authorization': 'Basic xyz'}
        });
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp.statusCode, 200);
        expect(resp.body, '{"name": "Thomas"}');
      });

      test("params['request']", () async {
        when(client.put(
          'http://localhost:3000/person',
          body: anyNamed("body"),
          headers: anyNamed("headers"),
          encoding: anyNamed("encoding"),
        )).thenAnswer((_) async => http.Response('{"name": "Guy"}', 200));

        final instance = DemoRestModel("Guy");
        final query = Query(params: {"request": "PUT"});
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp.statusCode, 200);
        expect(resp.body, '{"name": "Guy"}');
      });

      test("params['topLevelKey']", () async {
        when(client.post(
          'http://localhost:3000/person',
          body: '{"top":{"name":"Guy"}}',
          headers: anyNamed("headers"),
          encoding: anyNamed("encoding"),
        )).thenAnswer((_) async => http.Response('{"name": "Thomas"}', 200));

        final instance = DemoRestModel("Guy");
        final query = Query(params: {"topLevelKey": "top"});
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        verify(client.post(
          any,
          body: '{"top":{"name":"Guy"}}',
          headers: anyNamed("headers"),
          encoding: anyNamed("encoding"),
        ));

        expect(resp.statusCode, 200);
        expect(resp.body, '{"name": "Thomas"}');
      });
    });

    test("#delete", () async {
      when(client.delete(
        'http://localhost:3000/person',
        headers: anyNamed("headers"),
      )).thenAnswer((_) async => http.Response('{"name": "Thomas"}', 200));

      final instance = DemoRestModel("Guy");
      await provider.delete<DemoRestModel>(instance);

      verify(client.delete(
        'http://localhost:3000/person',
        headers: anyNamed("headers"),
      ));
    });

    test("#statusCodeIsSuccessful", () {
      expect(provider.statusCodeIsSuccessful(200), isTrue);
      expect(provider.statusCodeIsSuccessful(201), isTrue);
      expect(provider.statusCodeIsSuccessful(202), isTrue);
      expect(provider.statusCodeIsSuccessful(204), isTrue);
      expect(provider.statusCodeIsSuccessful(422), isFalse);
      expect(provider.statusCodeIsSuccessful(500), isFalse);
    });
  });

  group("RestAdapter", () {
    test("#toRest", () async {
      final m = DemoRestModel("Thomas");
      final payload = await DemoRestModelAdapter().toRest(m);
      expect(payload, containsPair("name", "Thomas"));
    });

    test("#fromRest", () async {
      final m = DemoRestModel("Thomas");
      final payload = await DemoRestModelAdapter().toRest(m);
      final newModel = await DemoRestModelAdapter().fromRest(payload);
      expect(newModel.name, "Thomas");
    });
  });
}
