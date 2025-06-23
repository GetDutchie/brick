import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase_generators/src/supabase_fields.dart';
import 'package:source_gen/source_gen.dart';

/// Generates Supabase/Postgres SQL CREATE TABLE statements from Dart model classes
class SupabaseSqlGenerator {
  /// Generate a CREATE TABLE SQL statement for a given model class
  static String generateCreateTableSql(ClassElement classElement, SupabaseSerializable config) {
    final fields = SupabaseFields(classElement, config);
    final tableName = config.tableName ?? _getDefaultTableName(classElement.name);

    final columns = <String>[];

    // Add primary key column (Supabase typically uses 'id' as primary key)
    columns.add('  id UUID PRIMARY KEY DEFAULT gen_random_uuid()');

    for (final field in fields.stableInstanceFields) {
      final annotation = fields.finder.annotationForField(field);

      // Skip ignored fields
      if (annotation.ignore) continue;

      // Skip associations (they'll be handled separately if needed)
      final checker = _getFieldChecker(field);
      if (checker.isSibling || (checker.isIterable && checker.isArgTypeASibling)) {
        continue;
      }

      final columnName = annotation.name ?? _toSnakeCase(field.name);
      final sqlType = _dartTypeToPostgresType(field.type);
      final constraints = <String>[];

      // Add constraints
      if (annotation.unique) constraints.add('UNIQUE');
      if (!field.type.getDisplayString().endsWith('?')) constraints.add('NOT NULL');
      if (annotation.defaultValue != null) {
        constraints.add("DEFAULT '${annotation.defaultValue}'");
      }

      final constraintString = constraints.isNotEmpty ? ' ${constraints.join(' ')}' : '';
      columns.add('  $columnName $sqlType$constraintString');
    }

    return '''CREATE TABLE $tableName (
${columns.join(',\n')}
);''';
  }

  /// Generate SQL for all models in a library
  static String generateAllTablesSql(LibraryReader library, List<SupabaseFields> allFields) {
    final sqlStatements = <String>[];

    for (final fields in allFields) {
      final classElement = fields.element;
      final config = _getSupabaseConfig(classElement);
      if (config != null) {
        final sql = generateCreateTableSql(classElement, config);
        sqlStatements.add('-- Table for ${classElement.name}');
        sqlStatements.add(sql);
        sqlStatements.add(''); // Empty line for readability
      }
    }

    return sqlStatements.join('\n');
  }

  /// Convert Dart type to Postgres type
  static String _dartTypeToPostgresType(DartType dartType) {
    final typeName = dartType.getDisplayString(withNullability: false);

    switch (typeName) {
      case 'String':
        return 'TEXT';
      case 'int':
        return 'INTEGER';
      case 'double':
        return 'REAL';
      case 'bool':
        return 'BOOLEAN';
      case 'DateTime':
        return 'TIMESTAMP WITH TIME ZONE';
      case 'List':
        return 'JSONB';
      case 'Map':
        return 'JSONB';
      default:
        // For enums and custom types, use TEXT
        return 'TEXT';
    }
  }

  /// Convert camelCase to snake_case
  static String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp('[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp('^_'), '');
  }

  /// Get default table name from class name
  static String _getDefaultTableName(String className) {
    return '${_toSnakeCase(className)}s';
  }

  /// Get Supabase configuration from class element
  static SupabaseSerializable? _getSupabaseConfig(ClassElement classElement) {
    // This is a simplified version - in practice, you'd need to parse the annotation
    // For now, return default config
    return SupabaseSerializable.defaults;
  }

  /// Get field checker for type analysis
  static _FieldChecker _getFieldChecker(FieldElement field) {
    return _FieldChecker(field.type);
  }
}

/// Simple field checker for type analysis
class _FieldChecker {
  final DartType type;

  _FieldChecker(this.type);

  bool get isSibling => false; // Simplified - would need proper type checking
  bool get isIterable => type.getDisplayString().startsWith('List<');
  bool get isArgTypeASibling => false; // Simplified
}
