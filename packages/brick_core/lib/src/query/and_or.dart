import 'package:brick_core/src/query/where.dart';

/// Append a required condition to the existing [WherePhrase]. Carries [this.required].
abstract class WhereConvenienceInterface {
  /// The Dart name of the field. For example, `myField` when querying `final String myField`.
  String get evaluatedField;

  final bool required;

  const WhereConvenienceInterface(
    this.required,
  );

  Where isExactly(dynamic value) =>
      Where(evaluatedField, value, compare: Compare.exact, required: required);

  Where isBetween(dynamic value1, dynamic value2) {
    assert(value1.runtimeType == value2.runtimeType, "Comparison values must be the same type");
    return Where(evaluatedField, [value1, value2], compare: Compare.between, required: required);
  }

  Where contains(dynamic value) =>
      Where(evaluatedField, value, compare: Compare.contains, required: required);

  Where isLessThan(dynamic value) =>
      Where(evaluatedField, value, compare: Compare.lessThan, required: required);

  Where isLessThanOrEqualTo(dynamic value) =>
      Where(evaluatedField, value, compare: Compare.lessThanOrEqualTo, required: required);

  Where isGreaterThan(dynamic value) =>
      Where(evaluatedField, value, compare: Compare.greaterThan, required: required);

  Where isGreaterThanOrEqualTo(dynamic value) =>
      Where(evaluatedField, value, compare: Compare.greaterThanOrEqualTo, required: required);

  Where isNot(dynamic value) =>
      Where(evaluatedField, value, compare: Compare.notEqual, required: required);
}

/// Generate a required condition.
class And extends WhereConvenienceInterface {
  final String evaluatedField;

  const And(
    this.evaluatedField,
  ) : super(true);
}

/// Generate an optional condition.
class Or extends WhereConvenienceInterface {
  final String evaluatedField;

  const Or(
    this.evaluatedField,
  ) : super(false);
}

class AndPhrase extends WherePhrase {
  const AndPhrase(List<WhereCondition> conditions) : super(conditions, required: true);
}

class OrPhrase extends WherePhrase {
  const OrPhrase(List<WhereCondition> conditions) : super(conditions, required: false);
}
