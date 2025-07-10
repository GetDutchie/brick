import 'package:brick_core/core.dart';
import 'package:brick_supabase/src/runtime_supabase_column_definition.dart';
import 'package:brick_supabase/src/supabase_adapter.dart';
import 'package:brick_supabase/src/supabase_model.dart';
import 'package:brick_supabase/src/supabase_model_dictionary.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

/// Create a prepared Supabase URI for eventual execution
class QuerySupabaseTransformer<_Model extends SupabaseModel> {
  ///
  final SupabaseAdapter adapter;

  ///
  final SupabaseModelDictionary modelDictionary;

  ///
  final Query? query;

  /// Create a prepared Supabase URI for eventual execution
  QuerySupabaseTransformer({
    required this.modelDictionary,
    this.query,
    SupabaseAdapter? adapter,
  }) : adapter = adapter ?? modelDictionary.adapterFor[_Model]!;

  /// All fields to be selected by the request, including associations and
  /// associations' fields
  String get selectFields =>
      destructureAssociationProperties(adapter.fieldsToSupabaseColumns, _Model).join(',');

  /// Translate all valid query properties to a composed PostgREST filter
  PostgrestTransformBuilder<List<Map<String, dynamic>>> applyQuery(
    PostgrestFilterBuilder<List<Map<String, dynamic>>> builder,
  ) {
    var computedBuilder = order(builder);

    final offset = query?.offset;
    if (offset != null) {
      final url = builder.overrideSearchParams('offset', (offset).toString());
      computedBuilder = computedBuilder.copyWithUrl(url);
    }

    return limit(computedBuilder);
  }

  ///
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select(SupabaseQueryBuilder builder) =>
      (query?.where ?? []).fold(builder.select(selectFields), (acc, condition) {
        final whereStatement = expandCondition(condition);
        for (final where in whereStatement) {
          for (final entry in where.entries) {
            final newUri = acc.appendSearchParams(entry.key, entry.value);
            acc = acc.copyWithUrl(newUri);
          }
        }
        return acc;
      });

  /// Convert association requests to a lookup by inferred association
  /// (`assoc(*)`) or by a rename (`my_assoc:assoc(*)`) or by a
  /// foreign key (`my_assoc:assoc!fk(*)`).
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
        if (field.query! != '') selectedFields.add(field.query!);
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
            definition.columnName: 'not.is.null',
          },
        ...associationConditions,
      ]);
    }

    final queryKey = (leadingAssociations != null ? '${leadingAssociations.join('.')}.' : '') +
        definition.columnName;

    return [
      {
        queryKey: condition.compare == Compare.inIterable
            ? (condition.value is Iterable && (condition.value as Iterable).isNotEmpty
                ? 'in.(${(condition.value as Iterable).join(',')})'
                : 'in.()')
            : '${_compareToSearchParam(condition.compare)}.${condition.value}',
      },
      ...associationConditions,
    ];
  }

  /// Produce a `limit` PostgREST filter from [Query.limit] and [Query.limitBy].
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(
    PostgrestFilterBuilder<List<Map<String, dynamic>>> builder,
  ) {
    if (query == null) return builder;

    final topLevelLimit = query?.limit;
    final withTopLevelLimit = topLevelLimit != null
        ? PostgrestTransformBuilder(
            builder.copyWithUrl(builder.appendSearchParams('limit', topLevelLimit.toString())),
          )
        : builder;

    return query!.limitBy.fold(withTopLevelLimit, (acc, limitBy) {
      final definition = adapter.fieldsToSupabaseColumns[limitBy.evaluatedField];
      final tableName = modelDictionary.adapterFor[definition?.associationType]?.supabaseTableName;
      if (tableName == null) return acc;

      final url = acc.appendSearchParams('$tableName.limit', limitBy.amount.toString());
      return PostgrestTransformBuilder(acc.copyWithUrl(url));
    });
  }

  /// Produce an `orderBy` PostgREST filter from [Query.orderBy].
  @protected
  @visibleForTesting
  PostgrestFilterBuilder<List<Map<String, dynamic>>> order(
    PostgrestFilterBuilder<List<Map<String, dynamic>>> builder,
  ) {
    if (query?.orderBy.isEmpty ?? true) return builder;

    return query!.orderBy.fold(builder, (acc, orderBy) {
      final definition = adapter.fieldsToSupabaseColumns[orderBy.evaluatedField];
      final tableName = modelDictionary.adapterFor[definition?.associationType]?.supabaseTableName;
      final columnName = adapter
          .fieldsToSupabaseColumns[orderBy.associationField ?? orderBy.evaluatedField]?.columnName;

      final url = acc.appendSearchParams(
        tableName == null ? 'order' : '$tableName.order',
        '$columnName.${orderBy.ascending ? 'asc' : 'desc'}.nullslast',
      );
      return acc.copyWithUrl(url);
    });
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
      case Compare.inIterable:
        throw ArgumentError('Compare.inIterable is not supported by _compareToSearchParam.');
    }
  }
}
