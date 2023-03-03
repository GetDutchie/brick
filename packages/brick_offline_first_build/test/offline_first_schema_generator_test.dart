import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_sqlite_generators/generators.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:brick_offline_first_build/src/offline_first_sqlite_builders.dart';

import 'offline_first_schema_generator/test_with_serdes.dart' as withSerdes;
import 'offline_first_schema_generator/test_with_association.dart' as withAssociation;
import 'offline_first_schema_generator/test_with_associations.dart' as withAssociations;

final generator = OfflineFirstSchemaGenerator();
final generateLibrary = generateLibraryForFolder('offline_first_schema_generator');
final annotationChecker = TypeChecker.fromRuntime(ConnectOfflineFirstWithRest);

Future<String> generateOutputForFile(String fileName) async {
  final reader = await generateLibrary(fileName);

  final annotatedElements = reader.annotatedWith(annotationChecker);
  final fieldses = annotatedElements.map((e) => SqliteFields(e.element as ClassElement)).toList();
  return generator.generate(reader, fieldses);
}

void main() {
  group('OfflineFirstSchemaGenerator', () {
    test('adds serdes member', () async {
      final reader = await generateLibrary('with_serdes');
      final annotatedElements = reader.annotatedWith(annotationChecker);
      final fieldses =
          annotatedElements.map((e) => SqliteFields(e.element as ClassElement)).toList();
      final output = generator.createMigration(reader, fieldses, version: 2);
      expect(output, withSerdes.output);
    });

    test('with association', () async {
      final output = await generateOutputForFile('with_association');
      expect(output, withAssociation.output);
    });

    test('with associations', () async {
      final output = await generateOutputForFile('with_associations');
      expect(output, withAssociations.output);
    });
  });
}
