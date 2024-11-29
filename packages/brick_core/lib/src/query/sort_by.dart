import 'package:brick_core/core.dart';
import 'package:brick_core/src/provider.dart';

class SortBy {
  /// The Dart name of the field. For example, `myField` when querying `final String myField`.
  ///
  /// The [Provider] should provide mappings between the field name
  /// and the remote source's expected name.
  final String evaluatedField;

  /// Defaults to `true`.
  final bool ascending;

  const SortBy(this.evaluatedField, {this.ascending = true});

  factory SortBy.fromJson(Map<String, dynamic> json) {
    return SortBy(
      json['evaluatedField'],
      ascending: json['ascending'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evaluatedField': evaluatedField,
      'ascending': ascending,
    };
  }

  @override
  String toString() => '$evaluatedField ${ascending ? 'ASC' : 'DESC'}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortBy && evaluatedField == other.evaluatedField && ascending == other.ascending;

  @override
  int get hashCode => evaluatedField.hashCode ^ ascending.hashCode;
}
