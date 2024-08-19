import 'package:brick_core/core.dart';
import 'package:brick_supabase/src/supabase_adapter.dart';
import 'package:brick_supabase/src/supabase_model_dictionary.dart';
import 'package:brick_supabase_abstract/brick_supabase_abstract.dart' hide Supabase;
import 'package:supabase/supabase.dart';

/// Create a prepared SQLite statement for eventual execution. Only [statement] and [values]
/// should be accessed.
///
/// Example (using SQLFlite):
/// ```dart
/// final sqliteQuery = QuerySqlTransformer(modelDictionary: dict, query: query);
/// final results = await (await db).rawQuery(sqliteQuery.statement, sqliteQuery.values);
/// ```
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
  }) : adapter = modelDictionary.adapterFor[_Model]!;

  String get selectQuery {
    return _destructureAssociation(adapter.fieldsToSupabaseColumns.values).join(',\n  ');
  }

  PostgrestFilterBuilder<List<Map<String, dynamic>>> select(SupabaseQueryBuilder builder) {
    return (query?.where ?? []).fold(builder.select(selectQuery), (acc, condition) {
      final whereStatement = _expandCondition(condition);
      for (final where in whereStatement) {
        for (final entry in where.entries) {
          final newUri = acc.appendSearchParams(entry.key, entry.value);
          acc = acc.copyWithUrl(newUri);
        }
      }
      return acc;
    });
  }

  List<String> _destructureAssociation(Iterable<RuntimeSupabaseColumnDefinition>? columns) {
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
        final fields = _destructureAssociation(
          modelDictionary.adapterFor[field.associationType!]?.fieldsToSupabaseColumns.values,
        );
        associationOutput += fields.join(',\n  ');
        associationOutput += ')';

        selectedFields.add(associationOutput);
        continue;
      }

      selectedFields.add(field.columnName);
    }

    return selectedFields;
  }

  String _compareToSearchParam(Compare compare) {
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

  /// Recursively step through a `Where` or `WherePhrase` to ouput a condition for `WHERE`.
  List<Map<String, String>> _expandCondition(
    WhereCondition condition, [
    SupabaseAdapter? passedAdapter,
  ]) {
    passedAdapter ??= adapter;

    // Begin a separate where phrase
    if (condition is WherePhrase) {
      final conditions = condition.conditions
          .map((c) => _expandCondition(c, passedAdapter))
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

      return _expandCondition(condition.value as WhereCondition, associationAdapter);
    }

    return [
      {
        definition.columnName: '${_compareToSearchParam(condition.compare)}.${condition.value}',
      }
    ];
  }
}
