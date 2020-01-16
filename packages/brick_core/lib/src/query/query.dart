import 'package:collection/collection.dart' show MapEquality, ListEquality;
import 'package:brick_core/src/query/where.dart';
import 'dart:convert';

const _mapEquality = MapEquality();
const _listEquality = ListEquality();

/// An interface to request data from a [Provider] or [Repository].
class Query {
  /// How this query interacts with its invoking provider.
  ///
  /// Often the invoking [Repository] will appropriately adjust the [action] when
  /// interacting with the provider. For example:
  /// ```dart
  ///   upsert(query) => final q = query.copyWith(action: QueryAction.upsert)
  /// ```
  final QueryAction action;

  /// Properties that interact with the provider's source. For example, `'limit'`.
  /// The value **must** be serializable by `jsonEncode`.
  final Map<String, dynamic> params;

  bool get unlimited => params['limit'] == null || params['limit'] < 1;

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
  /// Where('e-mail', '.org', compare: Compare.contains);
  ///
  /// // GOOD:
  /// Where('email', '.org', compare: Compare.contains);
  /// ```
  ///
  /// By default, every [WhereCondition] should be presumed to be an `and`.
  /// For example, `where: [Where('id', 1), Where('name', 'Thomas')]`
  /// will only return results where the ID is 1 and the name is Thomas.
  final List<WhereCondition> where;

  Query({
    this.action,
    Map<String, dynamic> params,
    this.where,
  }) : this.params = params ?? {} {
    /// Number of results first returned from query; `0` returns all. Must be greater than -1
    if (this.params['limit'] != null) {
      assert(this.params['limit'] > -1);
    }

    /// Offset results returned from query. Must be greater than -1 and must be used with limit
    if (this.params['offset'] != null) {
      assert(this.params['offset'] > -1);
      assert(this.params['limit'] != null);
    }
  }

  factory Query.fromJson(Map<String, dynamic> json) {
    return Query(
      action: json['action'] == null ? null : QueryAction.values[json['action']],
      params: json['params'],
      where: json['where'] == null ? null : json['where'].map((w) => WhereCondition.fromJson(w)),
    );
  }

  /// Make a _very_ simple query with a single [Where] statement.
  /// For example `Query.where('id', 1)`.
  ///
  /// [limit1] adds a limit param when `true`. Defaults to `false`.
  factory Query.where(
    String evaluatedField,
    dynamic value, {
    Compare compare,
    bool limit1 = false,
  }) {
    compare ??= Where.defaults.compare;
    return Query(
      where: [Where(evaluatedField, value, compare: compare)],
      params: {
        if (limit1) 'limit': 1,
      },
    );
  }

  Query copyWith({
    QueryAction action,
    Map<String, dynamic> params,
    List<WhereCondition> where,
  }) =>
      Query(
        action: action ?? this.action,
        params: params ?? this.params,
        where: where ?? this.where,
      );

  Map<String, dynamic> toJson() {
    return {
      if (action != null) 'action': QueryAction.values.indexOf(action),
      if (params != null) 'params': params,
      if (where != null)
        'where': where.map((w) => w.toJson()).toList().cast<Map<String, dynamic>>(),
    };
  }

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Query &&
          this?.action == other?.action &&
          _mapEquality.equals(this?.params, other?.params) &&
          _listEquality.equals(this?.where, other?.where);

  @override
  int get hashCode => action.hashCode ^ params.hashCode ^ where.hashCode;
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
}
