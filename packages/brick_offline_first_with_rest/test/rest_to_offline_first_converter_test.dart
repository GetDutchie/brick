import 'package:brick_offline_first_with_rest/rest_to_offline_first_converter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

MockClient _generateResponse(String response) {
  return MockClient((req) async {
    return http.Response('[{"name": "Thomas"}]', 200);
  });
}

void main() {
  group('RestToOfflineFirstConverter', () {
    group('#getRestPayload', () {
      test('with top-level array', () async {
        final converter = RestToOfflineFirstConverter(endpoint: 'http://0.0.0.0:3000/people')
          ..client = _generateResponse('[{"name": "Thomas"}]');

        final result = await converter.getRestPayload();
        expect(result, {'name': 'Thomas'});
      });

      test('with top-level map', () async {
        final converter = RestToOfflineFirstConverter(endpoint: 'http://0.0.0.0:3000/person')
          ..client = _generateResponse('[{"name": "Thomas"}]');

        final result = await converter.getRestPayload();
        expect(result, {'name': 'Thomas'});
      });

      test('with top-level key', () async {
        final converter = RestToOfflineFirstConverter(
          endpoint: 'http://0.0.0.0:3000/person',
          topLevelKey: 'person',
        )..client = _generateResponse('{ "person": { "name": "Thomas"} }');

        final result = await converter.getRestPayload();
        expect(result, {'name': 'Thomas'});
      });
    });

    test('#generateFields', () {
      final fields = {'name': 'Thomas', 'age': 26, 'pocket_change': 1.05};
      final converter = RestToOfflineFirstConverter(endpoint: 'http://0.0.0.0:3000/people');

      final fieldsOutput = converter.generateFields(fields);
      expect(fieldsOutput, '''  final int age;

  final String name;

  final double pocketChange;''');
    });

    test('#generateConstructorFields', () {
      final fields = {'name': 'Thomas', 'age': 26, 'pocket_change': 1.05};
      final converter = RestToOfflineFirstConverter(endpoint: 'http://0.0.0.0:3000/people');

      final fieldsOutput = converter.generateConstructorFields(fields);
      expect(fieldsOutput, '''    this.age,
    this.name,
    this.pocketChange''');
    });

    group('#generate', () {
      const expectedOutput = '''import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';

class PeopleRequestTransformer extends RestRequestTransformer {
  final get = const RestRequest(url: '/people');

  const PeopleRequestTransformer(Query? query, RestModel? instance)
    : super(query, instance);
}

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    fieldRename: FieldRename.snake,
    requestTransformer: PeopleRequestTransformer.new,
  ),
)
class People extends OfflineFirstModel {
  final String name;

  People({this.name});
}
''';
      test('from map', () async {
        final converter = RestToOfflineFirstConverter(endpoint: 'http://0.0.0.0:3000/people');
        final output = await converter.generate({'name': 'Thomas'});

        expect(output, expectedOutput);
      });

      test('from rest', () async {
        final converter = RestToOfflineFirstConverter(endpoint: 'http://0.0.0.0:3000/people')
          ..client = _generateResponse('[{"name": "Thomas"}]');

        final output = await converter.generate();
        expect(output, expectedOutput);
      });

      test('with topLevelKey', () async {
        final converter = RestToOfflineFirstConverter(
          endpoint: 'http://0.0.0.0:3000/people',
          topLevelKey: 'people',
        )..client = _generateResponse('{"people": [{"name": "Thomas"}]}');

        final output = await converter.generate();
        expect(output, contains("topLevelKey: 'people'"));
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
