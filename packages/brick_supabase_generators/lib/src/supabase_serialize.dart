import 'package:analyzer/dart/element/element.dart';
import 'package:brick_json_generators/json_serialize.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase_generators/src/supabase_fields.dart';
import 'package:brick_supabase_generators/src/supabase_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] to REST data
class SupabaseSerialize extends SupabaseSerdesGenerator
    with JsonSerialize<SupabaseModel, Supabase> {
  /// Generate a function to produce a [ClassElement] to REST data
  SupabaseSerialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });

  @override
  List<String> get instanceFieldsAndMethods {
    final fieldsToColumns = <String>[];
    final uniqueFields = <String>{};
    final config = (fields as SupabaseFields).config;

    for (final field in unignoredFields) {
      final annotation = fields.annotationForField(field);
      final checker = checkerForType(field.type);
      final columnName = providerNameForField(annotation.name, checker: checker);
      final isAssociation = checker.isSibling || (checker.isIterable && checker.isArgTypeASibling);

      var definition = '''
        '${field.name}': const RuntimeSupabaseColumnDefinition(
          association: $isAssociation,
          columnName: '$columnName',
      ''';
      if (isAssociation) definition += 'associationType: ${checker.withoutNullResultType},';
      if (isAssociation) definition += 'associationIsNullable: ${checker.isNullable},';
      if (annotation.foreignKey != null) definition += "foreignKey: '${annotation.foreignKey}',";
      if (annotation.query != null) definition += "query: '''${annotation.query}''',";
      definition += ')';
      fieldsToColumns.add(definition);

      if (annotation.unique) uniqueFields.add(field.name);
    }

    return [
      if (config?.defaultToNull != null)
        '@override\nfinal defaultToNull = ${config?.defaultToNull};',
      '@override\nfinal fieldsToSupabaseColumns = {${fieldsToColumns.join(',\n')}};',
      '@override\nfinal ignoreDuplicates = ${config?.ignoreDuplicates};',
      if (config?.onConflict != null) "@override\nfinal onConflict = '${config?.onConflict}';",
      '@override\nfinal uniqueFields = {${uniqueFields.map((u) => "'$u'").join(',\n')}};',
    ];
  }
}
