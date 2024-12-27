import 'package:brick_core/src/provider.dart';

/// Construct directions for a provider to sort its results.
class OrderBy {
  /// Defaults to `true`.
  final bool ascending;

  /// The Dart name of the field. For example, `myField` when querying `final String myField`.
  ///
  /// The [Provider] should provide mappings between the field name
  /// and the remote source's expected name.
  final String evaluatedField;

  /// The Dart name of the field of the association model
  /// if the [evaluatedField] is an association.
  ///
  /// If [evaluatedField] is not an association, this should be `null`.
  final String? associationField;

  /// Construct directions for a provider to sort its results.
  const OrderBy(
    this.evaluatedField, {
    this.ascending = true,
    this.associationField,
  });

  /// Sort by [ascending] order (A-Z).
  const OrderBy.asc(this.evaluatedField, {this.associationField}) : ascending = true;

  /// Sort by descending order (Z-A).
  const OrderBy.desc(this.evaluatedField, {this.associationField}) : ascending = false;

  /// Construct an [OrderBy] from a JSON map.
  factory OrderBy.fromJson(Map<String, dynamic> json) => OrderBy(
        json['evaluatedField'],
        ascending: json['ascending'],
        associationField: json['associationField'],
      );

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'ascending': ascending,
        if (associationField != null) 'associationField': associationField,
        'evaluatedField': evaluatedField,
      };

  @override
  String toString() => '$evaluatedField ${ascending ? 'ASC' : 'DESC'}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderBy &&
          evaluatedField == other.evaluatedField &&
          ascending == other.ascending &&
          associationField == other.associationField;

  @override
  int get hashCode => evaluatedField.hashCode ^ ascending.hashCode ^ associationField.hashCode;
}
