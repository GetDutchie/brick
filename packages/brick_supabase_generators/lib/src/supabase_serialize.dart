import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:brick_json_generators/json_serialize.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase_generators/src/supabase_fields.dart';
import 'package:brick_supabase_generators/src/supabase_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] to REST data
class SupabaseSerialize extends SupabaseSerdesGenerator
    with JsonSerialize<SupabaseModel, Supabase> {
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

      // T0D0 support List<Future<Sibling>> for 'association'
      fieldsToColumns.add(
        '''
          '${field.name}': const RuntimeSupabaseColumnDefinition(
            association: ${checker.isSibling || (checker.isIterable && checker.isArgTypeASibling)},
            associationForeignKey: '${annotation.foreignKey}',
            associationType: ${_finalTypeForField(field.type)},
            columnName: '$columnName',
          )''',
      );

      if (annotation.unique) uniqueFields.add(field.name);
    }

    return [
      if (config?.defaultToNull != null)
        '@override\nfinal defaultToNull = ${config?.defaultToNull};',
      '@override\nfinal fieldsToSupabaseColumns = {${fieldsToColumns.join(',\n')}};',
      '@override\nfinal ignoreDuplicates = ${config?.ignoreDuplicates};',
      if (config?.onConflict != null) '@override\nfinal onConflict = ${config?.onConflict};',
      '@override\nfinal uniqueFields = {${uniqueFields.map((u) => "'$u'").join(',\n')}};',
    ];
  }

  @override
  String? coderForField(field, checker, {required wrappedInFuture, required fieldAnnotation}) {
    // Supabase's API only accepts the active model
    // Recursive assocations are iteratively upserted
    if (checker.isSibling || (checker.isIterable && checker.isArgTypeASibling)) return null;

    return super.coderForField(
      field,
      checker,
      wrappedInFuture: wrappedInFuture,
      fieldAnnotation: fieldAnnotation,
    );
  }

  String _finalTypeForField(DartType type) {
    final checker = checkerForType(type);
    final typeRemover = RegExp(r'\<[,\s\w]+\>');

    // Future<?>, Iterable<?>
    if (checker.isFuture || checker.isIterable) {
      return _finalTypeForField(checker.argType);
    }

    if (checker.toJsonMethod != null) {
      return checker.toJsonMethod!.returnType
          .getDisplayString()
          .replaceAll('?', '')
          .replaceAll(typeRemover, '');
    }

    // remove arg types as they can't be declared in final fields
    return type.getDisplayString().replaceAll('?', '').replaceAll(typeRemover, '');
  }
}
