import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/builders.dart' show BaseBuilder;
import 'package:brick_sqlite_generators/sqlite_model_serdes_generator.dart';
import 'package:brick_sqlite_generators/src/sqlite_fields.dart';
import 'package:brick_sqlite_generators/src/sqlite_schema/sqlite_schema_generator.dart';
import 'package:build/build.dart';

export 'package:brick_build/src/annotation_super_generator.dart';

const _schemaGenerator = SqliteSchemaGenerator();

///
abstract class SqliteBaseBuilder<_ClassAnnotation> extends BaseBuilder<_ClassAnnotation> {
  ///
  SqliteSchemaGenerator get schemaGenerator => _schemaGenerator;

  ///
  SqliteBaseBuilder();

  ///
  Future<List<SqliteFields>> sqliteFieldsFromBuildStep(BuildStep buildStep) async {
    final annotatedElements = await getAnnotatedElements(buildStep);
    return annotatedElements.where((e) => e.element is ClassElement).map((e) {
      final sqlite = SqliteModelSerdesGenerator(e.element, e.annotation, repositoryName: '');
      return SqliteFields(sqlite.element as ClassElement, sqlite.config);
    }).toList();
  }
}
