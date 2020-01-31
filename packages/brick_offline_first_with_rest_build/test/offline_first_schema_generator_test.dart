import 'package:brick_build/testing.dart';
import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_sqlite_generators/generators.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import '../lib/src/offline_first_sqlite_builders.dart';

import 'offline_first_schema_generator/test_with_serdes.dart' as _$withSerdes;
import 'offline_first_schema_generator/test_with_association.dart' as _$withAssociation;
import 'offline_first_schema_generator/test_with_associations.dart' as _$withAssociations;

final generator = OfflineFirstSchemaGenerator();
final generateLibrary = generateLibraryForFolder('offline_first_schema_generator');
final annotationChecker = TypeChecker.fromRuntime(ConnectOfflineFirstWithRest);

Future<String> generateOutputForFile(String fileName) async {
  final reader = await generateLibrary(fileName);

  final annotatedElements = reader.annotatedWith(annotationChecker);
  final fieldses = annotatedElements.map((e) => SqliteFields(e.element)).toList();
  return generator.generate(reader, fieldses);
}

void main() {
  group('OfflineFirstSchemaGenerator', () {
    test('adds serdes member', () async {
      final reader = await generateLibrary('with_serdes');
      final annotatedElements = reader.annotatedWith(annotationChecker);
      final fieldses = annotatedElements.map((e) => SqliteFields(e.element)).toList();
      final output = generator.createMigration(reader, fieldses, version: 2);
      expect(output, _$withSerdes.output);
    });

    test('adds association', () async {
      final output = await generateOutputForFile('with_association');
      expect(output, _$withAssociation.output);
    });

    test('adds associations', () async {
      final output = await generateOutputForFile('with_associations');
      expect(output, _$withAssociations.output);
    });
  });
}
