import 'package:brick_core/core.dart';
import 'package:brick_supabase/src/runtime_supabase_column_definition.dart';
import 'package:brick_supabase/src/supabase_adapter.dart';
import 'package:brick_supabase/src/supabase_model.dart';
import 'package:brick_supabase/src/supabase_model_dictionary.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

/// Create a prepared Supabase URI for eventual execution
class QuerySupabaseTransformer<_Model extends SupabaseModel> {
  final SupabaseAdapter adapter;

  final SupabaseModelDictionary modelDictionary;

  /// Must-haves for the [statement], mainly used to build clauses
  final Query? query;

  /// [selectStatement] will output [statement] as a `SELECT FROM`. When false, the [statement]
  /// output will be a `SELECT COUNT(*)`. Defaults `true`.
  QuerySupabaseTransformer({
    required this.modelDictionary,
    this.query,
    SupabaseAdapter? adapter,
  }) : adapter = adapter ?? modelDictionary.adapterFor[_Model]!;

  String get selectFields {
    return destructureAssociationProperties(adapter.fieldsToSupabaseColumns.values).join(',');
  }

  PostgrestTransformBuilder<List<Map<String, dynamic>>> applyProviderArgs(
    PostgrestFilterBuilder<List<Map<String, dynamic>>> builder,
  ) {
    if (query?.providerArgs['orderBy'] != null) {
      builder = order(builder);
    }
    if (query?.providerArgs['limit'] != null) {
      return limit(builder);
    }
    return builder;
  }

  PostgrestFilterBuilder<List<Map<String, dynamic>>> select(SupabaseQueryBuilder builder) {
    return (query?.where ?? []).fold(builder.select(selectFields), (acc, condition) {
      final whereStatement = expandCondition(condition);
      for (final where in whereStatement) {
        for (final entry in where.entries) {
          final newUri = acc.appendSearchParams(entry.key, entry.value);
          acc = acc.copyWithUrl(newUri);
        }
      }
      return acc;
    });
  }

  @protected
  @visibleForTesting
  List<String> destructureAssociationProperties(
    Iterable<RuntimeSupabaseColumnDefinition>? columns,
  ) {
    final selectedFields = <String>[];

    if (columns == null) return selectedFields;

    for (final field in columns) {
      if (field.association && field.associationType != null) {
        var associationOutput =
            '${field.columnName}:${modelDictionary.adapterFor[field.associationType!]?.tableName}';
        if (field.associationForeignKey != null) {
          associationOutput += '!${field.associationForeignKey}';
        }
        associationOutput += '(';
        final fields = destructureAssociationProperties(
          modelDictionary.adapterFor[field.associationType!]?.fieldsToSupabaseColumns.values,
        );
        associationOutput += fields.join(',');
        associationOutput += ')';

        selectedFields.add(associationOutput);
        continue;
      }

      selectedFields.add(field.columnName);
    }

    return selectedFields;
  }

  /// Recursively step through a `Where` or `WherePhrase` to ouput a condition for `WHERE`.
  @protected
  @visibleForTesting
  List<Map<String, String>> expandCondition(
    WhereCondition condition, [
    SupabaseAdapter? passedAdapter,
    List<String>? leadingAssociations,
  ]) {
    passedAdapter ??= adapter;

    // Begin a separate where phrase
    if (condition is WherePhrase) {
      final conditions = condition.conditions
          .map((c) => expandCondition(c, passedAdapter))
          .expand((c) => c)
          .toList();

      if (condition.isRequired) {
        return conditions;
      }

      return [
        {
          'or': '(${conditions.map((c) => '${c.keys.first}.${c.values.first}').join(', ')})',
        }
      ];
    }

    if (!passedAdapter.fieldsToSupabaseColumns.containsKey(condition.evaluatedField)) {
      throw ArgumentError(
        'Field ${condition.evaluatedField} on $_Model is not serialized by SQLite',
      );
    }

    final definition = passedAdapter.fieldsToSupabaseColumns[condition.evaluatedField]!;

    if (definition.association) {
      if (condition.value is! WhereCondition) {
        throw ArgumentError(
          'Query value for association ${condition.evaluatedField} on $_Model must be a Where or WherePhrase',
        );
      }

      final associationAdapter = modelDictionary.adapterFor[definition.associationType]!;

      final newLeadingAssociations = [...leadingAssociations ?? <String>[], definition.columnName];
      return expandCondition(
        condition.value as WhereCondition,
        associationAdapter,
        newLeadingAssociations,
      );
    }

    return [
      {
        definition.columnName:
            '${_compareToSearchParam(condition.compare)}.${leadingAssociations != null ? '${leadingAssociations.join('.')}.' : ''}${condition.value}',
      }
    ];
  }

  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(
    PostgrestFilterBuilder<List<Map<String, dynamic>>> builder,
  ) {
    if (query?.providerArgs['limit'] == null) return builder;

    final limit = query!.providerArgs['limit'] as int;
    final referencedTable = query!.providerArgs['limitReferencedTable'] as String?;

    final key = referencedTable == null ? 'limit' : '$referencedTable.limit';

    final url = builder.appendSearchParams(key, '$limit');
    return PostgrestTransformBuilder(builder.copyWithUrl(url));
  }

  @protected
  @visibleForTesting
  PostgrestFilterBuilder<List<Map<String, dynamic>>> order(
    PostgrestFilterBuilder<List<Map<String, dynamic>>> builder,
  ) {
    if (query?.providerArgs['orderBy'] == null) return builder;

    final orderBy = query!.providerArgs['orderBy'] as String;
    final ascending = orderBy.toLowerCase().endsWith(' asc');
    final referencedTable = query!.providerArgs['orderByReferencedTable'] as String?;
    final key = referencedTable == null ? 'order' : '$referencedTable.order';
    final fieldName = orderBy.split(' ')[0];
    final columnName = adapter.fieldsToSupabaseColumns[fieldName]!.columnName;
    final value = '$columnName.${ascending ? 'asc' : 'desc'}.nullslast';
    final url = builder.overrideSearchParams(key, value);
    return builder.copyWithUrl(url);
  }

  static String _compareToSearchParam(Compare compare) {
    switch (compare) {
      case Compare.exact:
        return 'eq';
      case Compare.contains:
        return 'like';
      case Compare.doesNotContain:
        return 'not.like';
      case Compare.greaterThan:
        return 'gt';
      case Compare.greaterThanOrEqualTo:
        return 'gte';
      case Compare.lessThan:
        return 'lt';
      case Compare.lessThanOrEqualTo:
        return 'lte';
      case Compare.between:
        return 'adj';
      case Compare.notEqual:
        return 'neq';
    }
  }
}
