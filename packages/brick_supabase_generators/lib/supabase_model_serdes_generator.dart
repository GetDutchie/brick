import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase_generators/src/supabase_deserialize.dart';
import 'package:brick_supabase_generators/src/supabase_fields.dart';
import 'package:brick_supabase_generators/src/supabase_serialize.dart';

/// Digest a `supabaseConfig` (`@ConnectOfflineFirstWithSupabase`) from [reader] and manage serdes generators
/// to and from a `SupabaseProvider`.
class SupabaseModelSerdesGenerator extends ProviderSerializableGenerator<SupabaseSerializable> {
  /// Repository prefix passed to the generators. `Repository` will be appended and
  /// should not be included.
  final String? repositoryName;

  SupabaseModelSerdesGenerator(
    super.element,
    super.reader, {
    this.repositoryName,
  }) : super(configKey: 'supabaseConfig');

  @override
  SupabaseSerializable get config {
    if (reader.peek(configKey) == null) {
      return SupabaseSerializable.defaults;
    }

    return SupabaseSerializable(
      defaultToNull: withinConfigKey('defaultToNull')?.boolValue ??
          SupabaseSerializable.defaults.defaultToNull,
      ignoreDuplicates: withinConfigKey('ignoreDuplicates')?.boolValue ??
          SupabaseSerializable.defaults.ignoreDuplicates,
      onConflict:
          withinConfigKey('onConflict')?.stringValue ?? SupabaseSerializable.defaults.onConflict,
      tableName: withinConfigKey('fieldRename')!.stringValue,
    );
  }

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = SupabaseFields(classElement, config);
    return [
      SupabaseDeserialize(classElement, fields, repositoryName: repositoryName!),
      SupabaseSerialize(classElement, fields, repositoryName: repositoryName!),
    ];
  }
}
