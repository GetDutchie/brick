// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';

import 'package:brick_core/src/model_repository.dart';
import 'package:brick_core/src/provider.dart';
import 'package:brick_core/src/query/provider_query.dart';
import 'package:brick_core/src/query/sort_by.dart';
import 'package:brick_core/src/query/where.dart';
import 'package:collection/collection.dart' show ListEquality, MapEquality;

const _mapEquality = MapEquality();
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
  final List<ProviderQuery> forProviders;

  /// The response should not exceed this number.
  final int? limit;

  /// The response should start at this index.
  final int? offset;

  /// Properties that interact with the provider's source. For example, `'limit'`.
  /// The value **must** be serializable by `jsonEncode`.
  @Deprecated('Use limit, offset, sortBy, or forProviders instead')
  final Map<String, dynamic> providerArgs;

  final List<SortBy> sortBy;

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

  const Query({
    this.action,
    this.forProviders = const [],
    this.limit,
    this.offset,
    @Deprecated('Use limit, offset, sortBy, or forProviders instead.') this.providerArgs = const {},
    this.sortBy = const [],
    this.where,
  });

  factory Query.fromJson(Map<String, dynamic> json) {
    return Query(
      action: json['action'] == null ? null : QueryAction.values[json['action']],
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
      providerArgs: json['providerArgs'],
      sortBy: json['sortBy']?.map(SortBy.fromJson).toList() ?? [],
      where: json['where']?.map(WhereCondition.fromJson),
    );
  }

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
    compare ??= Where.defaults.compare;
    return Query(
      where: [Where(evaluatedField, value: value, compare: compare)],
      limit: limit1 ? 1 : null,
    );
  }

  Query copyWith({
    QueryAction? action,
    int? limit,
    int? offset,
    Map<String, dynamic>? providerArgs,
    List<SortBy>? sortBy,
    List<WhereCondition>? where,
  }) =>
      Query(
        action: action ?? this.action,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        providerArgs: providerArgs ?? this.providerArgs,
        sortBy: sortBy ?? this.sortBy,
        where: where ?? this.where,
      );

  Map<String, dynamic> toJson() {
    return {
      if (action != null) 'action': QueryAction.values.indexOf(action!),
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
      'providerArgs': providerArgs,
      if (sortBy.isNotEmpty) 'sortBy': sortBy.map((s) => s.toJson()).toList(),
      if (where != null) 'where': where!.map((w) => w.toJson()).toList(),
    };
  }

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Query &&
          action == other.action &&
          limit == other.limit &&
          offset == other.offset &&
          _mapEquality.equals(providerArgs, other.providerArgs) &&
          _listEquality.equals(sortBy, other.sortBy) &&
          _listEquality.equals(where, other.where);

  @override
  int get hashCode =>
      action.hashCode ^
      limit.hashCode ^
      offset.hashCode ^
      providerArgs.hashCode ^
      sortBy.hashCode ^
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
