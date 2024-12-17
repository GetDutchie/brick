import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase_generators/generators.dart';
import 'package:brick_supabase_generators/supabase_model_serdes_generator.dart';

class _OfflineFirstSupabaseSerialize extends SupabaseSerialize
    with OfflineFirstJsonSerialize<SupabaseModel, Supabase> {
  @override
  final OfflineFirstFields offlineFirstFields;

  _OfflineFirstSupabaseSerialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  }) : offlineFirstFields = OfflineFirstFields(element);
}

class _OfflineFirstSupabaseDeserialize extends SupabaseDeserialize
    with OfflineFirstJsonDeserialize<SupabaseModel, Supabase> {
  @override
  final OfflineFirstFields offlineFirstFields;

  _OfflineFirstSupabaseDeserialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  }) : offlineFirstFields = OfflineFirstFields(element);
}

///
class OfflineFirstSupabaseModelSerdesGenerator extends SupabaseModelSerdesGenerator {
  ///
  OfflineFirstSupabaseModelSerdesGenerator(
    super.element,
    super.reader, {
    required String super.repositoryName,
  });

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = SupabaseFields(classElement, config);
    return [
      _OfflineFirstSupabaseDeserialize(classElement, fields, repositoryName: repositoryName!),
      _OfflineFirstSupabaseSerialize(classElement, fields, repositoryName: repositoryName!),
    ];
  }
}
