import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/field_rename.dart';
import 'package:brick_supabase/brick_supabase.dart' show SupabaseSerializable;
import 'package:brick_supabase_generators/src/supabase_deserialize.dart';
import 'package:brick_supabase_generators/src/supabase_fields.dart';
import 'package:brick_supabase_generators/src/supabase_serialize.dart';

/// Digest a `supabaseConfig` (e.g. from a `@ConnectOfflineFirstWithSupabase`) from [reader] and manage serdes generators
/// to and from a `SupabaseProvider`.
class SupabaseModelSerdesGenerator extends ProviderSerializableGenerator<SupabaseSerializable> {
  /// Repository prefix passed to the generators. `Repository` will be appended and
  /// should not be included.
  final String? repositoryName;

  /// Digest a `supabaseConfig` (e.g. from a `@ConnectOfflineFirstWithSupabase`) from [reader] and manage serdes generators
  /// to and from a `SupabaseProvider`.
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
    final fieldRenameIndex =
        withinConfigKey('fieldRename')?.objectValue.getField('index')?.toIntValue();
    final fieldRename = fieldRenameIndex != null ? FieldRename.values[fieldRenameIndex] : null;

    return SupabaseSerializable(
      defaultToNull: withinConfigKey('defaultToNull')?.boolValue ??
          SupabaseSerializable.defaults.defaultToNull,
      fieldRename: fieldRename ?? SupabaseSerializable.defaults.fieldRename,
      ignoreDuplicates: withinConfigKey('ignoreDuplicates')?.boolValue ??
          SupabaseSerializable.defaults.ignoreDuplicates,
      onConflict:
          withinConfigKey('onConflict')?.stringValue ?? SupabaseSerializable.defaults.onConflict,
      tableName: withinConfigKey('tableName')?.stringValue ??
          StringHelpers.snakeCase('${element.displayName}s'),
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
