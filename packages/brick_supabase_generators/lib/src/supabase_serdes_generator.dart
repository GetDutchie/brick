import 'package:brick_json_generators/json_serdes_generator.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase_generators/src/supabase_fields.dart';

///
abstract class SupabaseSerdesGenerator extends JsonSerdesGenerator<SupabaseModel, Supabase> {
  ///
  SupabaseSerdesGenerator(
    super.element,
    SupabaseFields super.fields, {
    required super.repositoryName,
  }) : super(
          providerName: 'Supabase',
        );
}
