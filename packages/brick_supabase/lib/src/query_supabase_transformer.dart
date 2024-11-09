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
    return destructureAssociationProperties(adapter.fieldsToSupabaseColumns, _Model).join(',');
  }

  PostgrestTransformBuilder<List<Map<String, dynamic>>> applyProviderArgs(
    PostgrestFilterBuilder<List<Map<String, dynamic>>> builder,
  ) {
    if (query?.providerArgs['orderBy'] != null) {
      builder = order(builder);
    }

    if (query?.providerArgs['offset'] != null) {
      final url =
          builder.overrideSearchParams('offset', (query!.providerArgs['offset'] as int).toString());
      builder = builder.copyWithUrl(url);
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
    Map<String, RuntimeSupabaseColumnDefinition>? columns, [
    Type? destructuringFromType,
    int recursionDepth = 0,
  ]) {
    final selectedFields = <String>[];

    if (columns == null) return selectedFields;

    for (final entry in columns.entries) {
      final field = entry.value;
      if (field.query != null) {
        selectedFields.add(field.query!);
        continue;
      }

      if (field.association && field.associationType != null) {
        var associationOutput = field.columnName;
        if (modelDictionary.adapterFor[field.associationType!]?.supabaseTableName != null) {
          associationOutput +=
              ':${modelDictionary.adapterFor[field.associationType!]?.supabaseTableName}';
        }
        if (field.foreignKey != null) {
          associationOutput += '!${field.foreignKey}';
        }
        associationOutput += '(';

        // If a request includes a nested parent-child recursion, prevent the destructurization
        // from hitting a stack overflow by removing the association from the child destructure.
        //
        // For example, given `Parent(id:, child: Child(id:, parent:))`, this would strip the
        // association query without touching the parennt's original properties as
        // `parent(id, child(id, parent(id)))`.
        //
        // Implementations using looping associations like this should design for their
        // parent (first-level) models to accept null or empty child associations.
        var fieldsToDestructure =
            modelDictionary.adapterFor[field.associationType!]?.fieldsToSupabaseColumns;
        if (recursionDepth >= 1) {
          // Clone to avoid concurrent writes to the map
          fieldsToDestructure = {...?fieldsToDestructure}
            ..removeWhere((k, v) => v.associationType == destructuringFromType);
        }
        final fields = destructureAssociationProperties(
          fieldsToDestructure,
          field.associationType,
          recursionDepth + 1,
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
    List<Map<String, String>> associationConditions = const [],
  ]) {
    passedAdapter ??= adapter;

    // Begin a separate where phrase
    if (condition is WherePhrase) {
      final conditions = condition.conditions
          .map((c) => expandCondition(c, passedAdapter))
          .expand((c) => c)
          .toList();

      if (condition.isRequired) return conditions;

      return [
        {
          'or': '(${conditions.map((c) => '${c.keys.first}.${c.values.first}').join(', ')})',
        }
      ];
    }

    // The query most likely contains a field only serialized by another provider (i.e. SQLite).
    // Ignore this query and allow another provider to handle or ignore.
    // https://github.com/GetDutchie/brick/issues/424
    if (!passedAdapter.fieldsToSupabaseColumns.containsKey(condition.evaluatedField)) {
      return <Map<String, String>>[];
    }

    final definition = passedAdapter.fieldsToSupabaseColumns[condition.evaluatedField]!;

    if (definition.association) {
      if (condition.value is! WhereCondition) {
        throw ArgumentError(
          'Query value for association ${condition.evaluatedField} on $_Model must be a Where or WherePhrase',
        );
      }

      final associationAdapter = modelDictionary.adapterFor[definition.associationType]!;

      final newLeadingAssociations = [
        ...leadingAssociations ?? <String>[],
        associationAdapter.supabaseTableName,
      ];
      return expandCondition(
          condition.value as WhereCondition, associationAdapter, newLeadingAssociations, [
        if (!definition.associationIsNullable)
          {
            condition.evaluatedField: 'not.is.null',
          },
        ...associationConditions,
      ]);
    }

    final queryKey = (leadingAssociations != null ? '${leadingAssociations.join('.')}.' : '') +
        definition.columnName;

    return [
      {
        queryKey: '${_compareToSearchParam(condition.compare)}.${condition.value}',
      },
      ...associationConditions,
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
