// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';

import 'package:brick_core/src/model_repository.dart';
import 'package:brick_core/src/provider.dart';
import 'package:brick_core/src/query/limit_by.dart';
import 'package:brick_core/src/query/order_by.dart';
import 'package:brick_core/src/query/provider_query.dart';
import 'package:brick_core/src/query/where.dart';
import 'package:collection/collection.dart' show ListEquality;

const _listEquality = ListEquality();

/// An interface to request data from a [Provider] or [ModelRepository].
class Query {
  /// How this query interacts with its invoking provider.
  ///
  /// Often the invoking [ModelRepository] will appropriately adjust the [action] when
  /// interacting with the provider. For example:
  /// ```dart
  ///   upsert(query) => final q = query.copyWith(action: QueryAction.upsert)
  /// ```
  final QueryAction? action;

  /// [Provider]-specific query arguments.
  /// Only one [ProviderQuery] per [Provider] is permitted.
  final List<ProviderQuery> forProviders;

  /// The response should not exceed this number.
  /// For advanced cases, see [limitBy].
  final int? limit;

  /// Directions for limiting associated model results before they're returned to the caller.
  /// [limit] will restrict the top-level queried model.
  final List<LimitBy> limitBy;

  /// The response should start at this index.
  final int? offset;

  /// Directions for sorting results before they're returned to the caller.
  final List<OrderBy> orderBy;

  /// Available for [Provider]s to easily access their relevant
  /// [ProviderQuery]s.
  Map<Type, ProviderQuery> get providerQueries =>
      forProviders.fold(<Type, ProviderQuery>{}, (acc, p) {
        acc[p.provider] = p;
        return acc;
      });

  /// When [limit] is undefined or less than 1, the query is considered "unlimited".
  bool get unlimited => limit == null || limit! < 1;

  /// Model properties to be interpreted by the [Provider].
  /// When creating [WhereCondition]s, the first positional `fieldName` argument
  /// should be the _field name_, not the name used between the provider
  /// and source (e.g. `data['last_name']`).
  ///
  /// ```dart
  /// @Rest(name: "e-mail")
  /// final String email;
  ///
  /// // BAD:
  /// Where('e-mail').contains('.org');
  ///
  /// // GOOD:
  /// Where('email').contains('.org');
  /// ```
  ///
  /// By default, every [WhereCondition] should be presumed to be an `and`.
  /// For example, `where: [Where.exact('id', 1), Where.exact('name', 'Thomas')]`
  /// will only return results where the ID is 1 **and** the name is Thomas.
  final List<WhereCondition>? where;

  /// An interface to request data from a [Provider] or [ModelRepository].
  const Query({
    this.action,
    this.forProviders = const [],
    this.limit,
    this.limitBy = const [],
    this.offset,
    this.orderBy = const [],
    this.where,
  })  : assert(limit == null || limit > -1, 'limit must be greater than 0'),
        assert(offset == null || offset > -1, 'offset must be greater than 0');

  /// Deserialize from JSON
  factory Query.fromJson(Map<String, dynamic> json) => Query(
        action: json['action'] == null ? null : QueryAction.values[json['action']],
        limit: json['limit'] as int?,
        limitBy: json['limitBy']?.map(LimitBy.fromJson).toList() ?? [],
        offset: json['offset'] as int?,
        orderBy: json['orderBy']?.map(OrderBy.fromJson).toList() ?? [],
        where: json['where']?.map(WhereCondition.fromJson),
      );

  /// Make a _very_ simple query with a single [Where] statement.
  /// For example `Query.where('id', 1)`.
  ///
  /// [limit1] adds a limit param when `true`. Defaults to `false`.
  factory Query.where(
    String evaluatedField,
    value, {
    Compare? compare,
    bool limit1 = false,
  }) {
    return Query(
      where: [
        Where(
          evaluatedField,
          value: value,
          compare: compare ?? Where.defaults.compare,
        ),
      ],
      limit: limit1 ? 1 : null,
    );
  }

  /// Reconstruct the [Query] with passed overrides
  Query copyWith({
    QueryAction? action,
    List<ProviderQuery>? forProviders,
    int? limit,
    List<LimitBy>? limitBy,
    int? offset,
    List<OrderBy>? orderBy,
    List<WhereCondition>? where,
  }) =>
      Query(
        action: action ?? this.action,
        forProviders: forProviders ?? this.forProviders,
        limit: limit ?? this.limit,
        limitBy: limitBy ?? this.limitBy,
        offset: offset ?? this.offset,
        orderBy: orderBy ?? this.orderBy,
        where: where ?? this.where,
      );

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        if (action != null) 'action': QueryAction.values.indexOf(action!),
        if (forProviders.isNotEmpty) 'forProviders': forProviders.map((p) => p.toJson()).toList(),
        if (limit != null) 'limit': limit,
        if (limitBy.isNotEmpty) 'limitBy': limitBy.map((l) => l.toJson()).toList(),
        if (offset != null) 'offset': offset,
        if (orderBy.isNotEmpty) 'orderBy': orderBy.map((s) => s.toJson()).toList(),
        if (where != null) 'where': where!.map((w) => w.toJson()).toList(),
      };

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Query &&
          action == other.action &&
          limit == other.limit &&
          offset == other.offset &&
          _listEquality.equals(forProviders, other.forProviders) &&
          _listEquality.equals(limitBy, other.limitBy) &&
          _listEquality.equals(orderBy, other.orderBy) &&
          _listEquality.equals(where, other.where);

  @override
  int get hashCode =>
      action.hashCode ^
      forProviders.hashCode ^
      limit.hashCode ^
      limitBy.hashCode ^
      offset.hashCode ^
      orderBy.hashCode ^
      where.hashCode;
}

/// How the query interacts with the provider
enum QueryAction {
  /// Retrieve from provider (the default)
  get,

  /// Create in the provider
  insert,

  /// Modify existing data in the provider
  update,

  /// Insert or update from provider
  upsert,

  /// Remove from provider
  delete,

  /// Listen for streaming changes
  subscribe,
}
