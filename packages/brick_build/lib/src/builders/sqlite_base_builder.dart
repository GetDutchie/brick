import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/annotation_super_generator.dart';
import 'package:brick_build/src/builders/base.dart';
import 'package:brick_build/src/offline_first/sqlite_serdes.dart';
import 'package:brick_build/src/sqlite_schema/sqlite_schema_generator.dart';
import 'package:brick_build/src/sqlite_serdes/sqlite_fields.dart';

export 'package:brick_build/src/annotation_super_generator.dart';

const _schemaGenerator = SqliteSchemaGenerator();

abstract class SqliteBaseBuilder extends BaseBuilder {
  SqliteSchemaGenerator get schemaGenerator => _schemaGenerator;

  SqliteBaseBuilder(AnnotationSuperGenerator generator) : super(generator);

  Future<List<SqliteFields>> sqliteFieldsFromBuildStep(BuildStep buildStep) async {
    final annotatedElements = await getAnnotatedElements(buildStep);
    return annotatedElements.where((e) => e.element is ClassElement).map((e) {
      final sqlite = SqliteSerdes(e.element, e.annotation);
      return SqliteFields(sqlite.element as ClassElement, sqlite.config);
    }).toList();
  }
}
