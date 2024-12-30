import 'dart:convert';

import 'package:brick_core/src/adapter.dart';

/// Construct directions for a provider to limit its results.
class LimitBy {
  /// The ceiling for how many results can be returned for [evaluatedField].
  final int amount;

  /// Some providers may support limiting based on a model retrieved by the query.
  /// This Dart field name should be accessible to the [Adapter]'s definitions
  /// (e.g. a `RuntimeSqliteColumnDefinition` map).
  final String evaluatedField;

  /// Construct directions for a provider to limit its results.
  const LimitBy(
    this.amount, {
    required this.evaluatedField,
  });

  /// Construct a [LimitBy] from a JSON map.
  factory LimitBy.fromJson(Map<String, dynamic> json) => LimitBy(
        json['amount'],
        evaluatedField: json['evaluatedField'],
      );

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'evaluatedField': evaluatedField,
      };

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LimitBy && amount == other.amount && evaluatedField == other.evaluatedField;

  @override
  int get hashCode => amount.hashCode ^ evaluatedField.hashCode;
}
