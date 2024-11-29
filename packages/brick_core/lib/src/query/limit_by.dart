import 'dart:convert';

import 'package:brick_core/src/model.dart';
import 'package:brick_core/src/model_dictionary.dart';
import 'package:brick_core/src/provider.dart';

/// Construct directions for a provider to limit its results.
class LimitBy {
  /// The ceiling for how many results can be returned for a [model].
  final int amount;

  /// Some providers may support limiting based on a model retrieved by the query.
  /// This [Model] should be accessible to the [Provider]'s [ModelDictionary].
  final Type model;

  /// Construct directions for a provider to limit its results.
  const LimitBy(
    this.amount, {
    required this.model,
  });

  /// Construct a [LimitBy] from a JSON map.
  factory LimitBy.fromJson(Map<String, dynamic> json) => LimitBy(
        json['amount'],
        model: json['model'],
      );

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'model': model,
      };

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LimitBy && amount == other.amount && model == other.model;

  @override
  int get hashCode => amount.hashCode ^ model.hashCode;
}
