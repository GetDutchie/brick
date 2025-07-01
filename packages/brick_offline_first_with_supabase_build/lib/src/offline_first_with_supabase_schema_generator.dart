import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_offline_first_with_supabase_build/src/supabase_sql_generator.dart';
import 'package:brick_sqlite_generators/generators.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase_generators/src/supabase_fields.dart';
import 'package:source_gen/source_gen.dart';

/// Custom schema generator that adds Supabase SQL generation to migration files
class OfflineFirstWithSupabaseSchemaGenerator extends OfflineFirstSchemaGenerator {
  @override
  String? createMigration(LibraryReader library, List<SqliteFields> fieldses, {int? version}) {
    // First, generate the normal migration content
    final migrationContent = super.createMigration(library, fieldses, version: version);

    if (migrationContent == null) return null;

    // Extract Supabase fields from the same models
    final supabaseFields = _extractSupabaseFields(library);

    // Generate Supabase SQL
    final supabaseSql = SupabaseSqlGenerator.generateAllTablesSql(library, supabaseFields);

    // Combine SQL comment with migration content
    return _addSupabaseSqlComment(migrationContent, supabaseSql);
  }

  /// Extract Supabase fields from models in the library
  List<SupabaseFields> _extractSupabaseFields(LibraryReader library) {
    final supabaseFields = <SupabaseFields>[];
    const annotationChecker = TypeChecker.fromRuntime(ConnectOfflineFirstWithSupabase);

    final annotatedElements = library.annotatedWith(annotationChecker);

    for (final annotatedElement in annotatedElements) {
      if (annotatedElement.element is ClassElement) {
        final classElement = annotatedElement.element as ClassElement;
        final config = _parseSupabaseConfig(annotatedElement.annotation);
        supabaseFields.add(SupabaseFields(classElement, config));
      }
    }

    return supabaseFields;
  }

  /// Parse Supabase configuration from annotation
  SupabaseSerializable? _parseSupabaseConfig(ConstantReader reader) {
    try {
      final supabaseConfig = reader.read('supabaseConfig');

      if (supabaseConfig.isNull) {
        return SupabaseSerializable.defaults;
      }

      // Parse the configuration - this is a simplified version
      // In practice, you'd need to parse all the fields from the annotation
      return SupabaseSerializable.defaults;
    } catch (e) {
      // If parsing fails, return defaults
      return SupabaseSerializable.defaults;
    }
  }

  /// Add Supabase SQL as a comment to the migration content
  String _addSupabaseSqlComment(String migrationContent, String supabaseSql) {
    if (supabaseSql.trim().isEmpty) {
      return migrationContent;
    }

    final sqlComment = supabaseSql.split('\n').map((line) => '// $line').join('\n');

    return '''// Equivalent Supabase SQL:
$sqlComment

$migrationContent''';
  }
}
