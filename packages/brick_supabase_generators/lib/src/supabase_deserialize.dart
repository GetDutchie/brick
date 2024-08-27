import 'package:analyzer/dart/element/element.dart';
import 'package:brick_json_generators/json_deserialize.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase_generators/src/supabase_fields.dart';
import 'package:brick_supabase_generators/src/supabase_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] from REST data
class SupabaseDeserialize extends SupabaseSerdesGenerator
    with JsonDeserialize<SupabaseModel, Supabase> {
  SupabaseDeserialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });

  @override
  List<String> get instanceFieldsAndMethods {
    final config = (fields as SupabaseFields).config;

    return [
      "@override\nfinal supabaseTableName = ${config!.tableName == null ? 'null' : "'${config.tableName}'"};",
    ];
  }
}
