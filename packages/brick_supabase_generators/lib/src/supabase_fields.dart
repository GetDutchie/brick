// Generously inspired by JsonSerializable

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_supabase/brick_supabase.dart';

/// Find `@Supabase` given a field
class SupabaseAnnotationFinder extends AnnotationFinder<Supabase> {
  final SupabaseSerializable? config;

  SupabaseAnnotationFinder([this.config]);

  /// Change serialization key based on the configuration.
  /// `name` defined with a field annotation (`@Graphql`) take precedence.
  String _renameField(String name) {
    final renameTo = config?.fieldRename ?? SupabaseSerializable.defaults.fieldRename;
    switch (renameTo) {
      case FieldRename.none:
        return name;
      case FieldRename.snake:
        return StringHelpers.snakeCase(name);
      case FieldRename.kebab:
        return StringHelpers.kebabCase(name);
      case FieldRename.pascal:
        return StringHelpers.pascalCase(name);
    }
  }

  @override
  Supabase from(element) {
    final obj = objectForField(element);

    if (obj == null) {
      return Supabase(
        ignore: Supabase.defaults.ignore,
        ignoreFrom: Supabase.defaults.ignoreFrom,
        ignoreTo: Supabase.defaults.ignoreTo,
        name: _renameField(element.name),
        nullable: Supabase.defaults.nullable,
        enumAsString: Supabase.defaults.enumAsString,
      );
    }

    return Supabase(
      defaultValue: obj.getField('defaultValue')!.toStringValue(),
      enumAsString: obj.getField('enumAsString')!.toBoolValue() ?? Supabase.defaults.enumAsString,
      fromGenerator: obj.getField('fromGenerator')!.toStringValue(),
      foreignKey: obj.getField('foreignKey')!.toStringValue(),
      ignore: obj.getField('ignore')!.toBoolValue() ?? Supabase.defaults.ignore,
      ignoreFrom: obj.getField('ignoreFrom')!.toBoolValue() ?? Supabase.defaults.ignoreFrom,
      ignoreTo: obj.getField('ignoreTo')!.toBoolValue() ?? Supabase.defaults.ignoreTo,
      name: obj.getField('name')?.toStringValue() ?? _renameField(element.name),
      nullable: obj.getField('nullable')!.toBoolValue() ?? Supabase.defaults.nullable,
      toGenerator: obj.getField('toGenerator')!.toStringValue(),
      unique: obj.getField('unique')!.toBoolValue() ?? Supabase.defaults.unique,
    );
  }
}

/// Converts all fields to [Supabase]s for later consumption
class SupabaseFields extends FieldsForClass<Supabase> {
  @override
  final SupabaseAnnotationFinder finder;
  final SupabaseSerializable? config;

  SupabaseFields(ClassElement element, [this.config])
      : finder = SupabaseAnnotationFinder(config),
        super(element: element);
}
