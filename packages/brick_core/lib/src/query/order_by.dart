import 'package:brick_core/src/model.dart';
import 'package:brick_core/src/model_dictionary.dart';
import 'package:brick_core/src/provider.dart';
import 'package:meta/meta.dart';

/// Construct directions for a provider to sort its results.
@immutable
class OrderBy {
  /// Defaults to `true`.
  final bool ascending;

  /// The Dart name of the field. For example, `myField` when querying `final String myField`.
  ///
  /// The [Provider] should provide mappings between the field name
  /// and the remote source's expected name.
  final String evaluatedField;

  /// Some providers may support ordering based on a model retrieved by the query.
  /// This [Model] should be accessible to the [Provider]'s [ModelDictionary].
  final Type? model;

  /// Construct directions for a provider to sort its results.
  const OrderBy(
    this.evaluatedField, {
    this.ascending = true,
    this.model,
  });

  /// Sort by [ascending] order (A-Z).
  factory OrderBy.asc(String evaluatedField, {Type? model}) =>
      OrderBy(evaluatedField, model: model);

  /// Sort by descending order (Z-A).
  factory OrderBy.desc(String evaluatedField, {Type? model}) =>
      OrderBy(evaluatedField, ascending: false, model: model);

  /// Construct an [OrderBy] from a JSON map.
  factory OrderBy.fromJson(Map<String, dynamic> json) => OrderBy(
        json['evaluatedField'],
        ascending: json['ascending'],
      );

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'ascending': ascending,
        'evaluatedField': evaluatedField,
        if (model != null) 'model': model?.toString(),
      };

  @override
  String toString() => '$evaluatedField ${ascending ? 'ASC' : 'DESC'}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderBy &&
          evaluatedField == other.evaluatedField &&
          ascending == other.ascending &&
          model == other.model;

  @override
  int get hashCode => evaluatedField.hashCode ^ ascending.hashCode ^ model.hashCode;
}
