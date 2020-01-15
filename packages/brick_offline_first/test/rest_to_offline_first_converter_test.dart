import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import '../lib/rest_to_offline_first_converter.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  final client = MockClient();

  group('RestToOfflineFirstConverter', () {
    group('#getRestPayload', () {
      test('with top-level array', () async {
        when(client.get('http://localhost:3000/people'))
            .thenAnswer((_) async => http.Response('[{"name": "Thomas"}]', 200));

        final converter = RestToOfflineFirstConverter(endpoint: 'http://localhost:3000/people');
        converter.client = client;

        final result = await converter.getRestPayload();
        expect(result, {'name': 'Thomas'});
      });

      test('with top-level map', () async {
        when(client.get('http://localhost:3000/person'))
            .thenAnswer((_) async => http.Response('{"name": "Thomas"}', 200));

        final converter = RestToOfflineFirstConverter(endpoint: 'http://localhost:3000/person');
        converter.client = client;

        final result = await converter.getRestPayload();
        expect(result, {'name': 'Thomas'});
      });

      test('with top-level key', () async {
        when(client.get('http://localhost:3000/person'))
            .thenAnswer((_) async => http.Response('{ "person": { "name": "Thomas"} }', 200));

        final converter = RestToOfflineFirstConverter(
            endpoint: 'http://localhost:3000/person', topLevelKey: 'person');
        converter.client = client;

        final result = await converter.getRestPayload();
        expect(result, {'name': 'Thomas'});
      });
    });

    test('#generateFields', () {
      final fields = {'name': 'Thomas', 'age': 26, 'pocket_change': 1.05};
      final converter = RestToOfflineFirstConverter(endpoint: 'http://localhost:3000/people');

      final fieldsOutput = converter.generateFields(fields);
      expect(fieldsOutput, '''  final int age;

  final String name;

  final double pocketChange;''');
    });

    test('#generateConstructorFields', () {
      final fields = {'name': 'Thomas', 'age': 26, 'pocket_change': 1.05};
      final converter = RestToOfflineFirstConverter(endpoint: 'http://localhost:3000/people');

      final fieldsOutput = converter.generateConstructorFields(fields);
      expect(fieldsOutput, '''    this.age,
    this.name,
    this.pocketChange''');
    });

    group('#generate', () {
      final expectedOutput = '''import 'package:brick_offline_first/offline_first.dart';
import 'package:brick_offline_first_abstract/annotations.dart';

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    fieldRename: FieldRename.snake,
    endpoint: "=> '/people';",
  ),
)
class People extends OfflineFirstModel {
  final String name;

  People({
    this.name,
  });
}
''';
      test('from map', () async {
        final converter = RestToOfflineFirstConverter(endpoint: 'http://localhost:3000/people');
        final output = await converter.generate({'name': 'Thomas'});

        expect(output, expectedOutput);
      });

      test('from rest', () async {
        when(client.get('http://localhost:3000/people'))
            .thenAnswer((_) async => http.Response('[{"name": "Thomas"}]', 200));

        final converter = RestToOfflineFirstConverter(endpoint: 'http://localhost:3000/people');
        converter.client = client;

        final output = await converter.generate();
        expect(output, expectedOutput);
      });

      test('with topLevelKey', () async {
        when(client.get('http://localhost:3000/people'))
            .thenAnswer((_) async => http.Response('{"people": [{"name": "Thomas"}]}', 200));

        final converter = RestToOfflineFirstConverter(
            endpoint: 'http://localhost:3000/people', topLevelKey: 'people');
        converter.client = client;
        final output = await converter.generate();
        expect(output, contains("fromKey: 'people',"));
      });
    });

    test('.toCamelCase', () {
      final snake = RestToOfflineFirstConverter.toCamelCase('from_snake_case');
      expect(snake, 'fromSnakeCase');

      final kebab = RestToOfflineFirstConverter.toCamelCase('from-kebab-case');
      expect(kebab, 'fromKebabCase');
    });
  });
}
