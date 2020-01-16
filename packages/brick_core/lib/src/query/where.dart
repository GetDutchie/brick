import 'package:collection/collection.dart' show ListEquality;
import 'dart:convert';

const _listEquality = ListEquality();

/// Lower-level control over the value of a `Query#where` map.
///
/// Example:
/// ```dart
/// Query(where: [
///   Where.exact('myField', 'must_match_this_value')
///   Where('myOtherField').contains('must_contain_this_value'),
/// ])
/// ```
abstract class WhereCondition {
  /// The Dart name of the field. For example, `myField` when querying `final String myField`.
  ///
  /// The [Provider] should provide mappings between the field name
  /// and the remote source's expected name.
  String get evaluatedField;

  /// Nested conditions. Leave unchanged for [WhereCondition]s that do not nest.
  final List<WhereCondition> conditions = null;

  /// The kind of comparison of the [evaluatedField] to the [value]. Defaults to [Compare.equals].
  /// It is the responsibility of the [Provider] to ignore or interpret the requested comparison.
  Compare get compare;

  /// Whether the condition(s) must evaluate to true. Defaults `true`.
  ///
  /// For example, `true` would translate to `AND` in SQL instead of `OR`.
  /// Some [Provider]s may ignore this field.
  bool get required;

  /// The value to compare on the [evaluatedField].
  dynamic get value;

  const WhereCondition();

  factory WhereCondition.fromJson(Map<String, dynamic> data) {
    if (data['subclass'] == 'WherePhrase') {
      return WherePhrase(
        data['conditions'].map((s) => WhereCondition.fromJson(s)),
        required: data['required'],
      );
    }

    return Where(
      data['evaluatedField'],
      ofValue: data['value'],
      compare: Compare.values[data['compare']],
      required: data['required'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subclass': runtimeType.toString(),
      if (evaluatedField != null) 'evaluatedField': evaluatedField,
      if (compare != null) 'compare': Compare.values.indexOf(compare),
      if (conditions != null)
        'conditions': conditions.map((s) => s.toJson()).toList().cast<Map<String, dynamic>>(),
      if (required != null) 'required': required,
      if (value != null) 'value': value,
    };
  }

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) => identical(this, other) ||
          other is WhereCondition &&
              evaluatedField == other?.evaluatedField &&
              compare == other?.compare &&
              required == other?.required &&
              _listEquality.equals(conditions, other?.conditions) &&
              value is List
      ? _listEquality.equals(value, (other as WhereCondition)?.value)
      : value == (other as WhereCondition)?.value;

  @override
  int get hashCode =>
      evaluatedField.hashCode ^
      compare.hashCode ^
      conditions.hashCode ^
      required.hashCode ^
      value.hashCode;
}

class Where extends WhereCondition {
  final String evaluatedField;
  final Compare compare;
  final dynamic value;
  final bool required;

  static const defaults = const Where(
    '',
    compare: Compare.exact,
    required: true,
  );

  /// A condition that evaluates to `true`  in the [Provider] should return [Model](s).
  ///
  /// This class should be exposed by the implemented [Repository] and not imported from
  /// this package as repositories may choose to extend or inhibit functionality.
  const Where(
    this.evaluatedField, {
    dynamic ofValue,
    Compare compare,
    bool required,
  })  : this.required = required ?? true,
        this.compare = compare ?? Compare.exact,
        this.value = ofValue;

  /// A condition written with brevity. ALways [required].
  factory Where.exact(String evaluatedField, dynamic value) =>
      Where(evaluatedField, ofValue: value, compare: Compare.exact, required: true);

  Where isExactly(dynamic value) =>
      Where(evaluatedField, ofValue: value, compare: Compare.exact, required: required);

  Where isBetween(dynamic value1, dynamic value2) {
    assert(value1.runtimeType == value2.runtimeType, "Comparison values must be the same type");
    return Where(evaluatedField,
        ofValue: [value1, value2], compare: Compare.between, required: required);
  }

  Where contains(dynamic value) =>
      Where(evaluatedField, ofValue: value, compare: Compare.contains, required: required);

  Where isLessThan(dynamic value) =>
      Where(evaluatedField, ofValue: value, compare: Compare.lessThan, required: required);

  Where isLessThanOrEqualTo(dynamic value) =>
      Where(evaluatedField, ofValue: value, compare: Compare.lessThanOrEqualTo, required: required);

  Where isGreaterThan(dynamic value) =>
      Where(evaluatedField, ofValue: value, compare: Compare.greaterThan, required: required);

  Where isGreaterThanOrEqualTo(dynamic value) => Where(evaluatedField,
      ofValue: value, compare: Compare.greaterThanOrEqualTo, required: required);

  Where isNot(dynamic value) =>
      Where(evaluatedField, ofValue: value, compare: Compare.notEqual, required: required);

  /// Recursively find conditions that evaluate a specific field. A field is a member on a model,
  /// such as `myUserId` in `final String myUserId`.
  /// If the use case for the field only requires one result, say `id` or `primaryKey`,
  /// [firstByField] may be more useful.
  static List<WhereCondition> byField(String fieldName, List<WhereCondition> conditions) {
    final flattenedConditions = <WhereCondition>[];

    /// recursively flatten all nested conditions
    void expandConditions(WhereCondition condition) {
      if (condition?.conditions == null || condition.conditions.isEmpty) {
        flattenedConditions.add(condition);
      } else {
        condition?.conditions?.forEach(expandConditions);
      }
    }

    conditions?.forEach(expandConditions);

    return flattenedConditions
        ?.where((c) => c.evaluatedField == fieldName)
        ?.toList()
        ?.cast<WhereCondition>();
  }

  /// Find the first occurrance of a condition that evaluates a specific field
  /// For all conditions, use [byField].
  static Where firstByField(String fieldName, List<WhereCondition> conditions) {
    final results = byField(fieldName, conditions);
    if (results?.isEmpty ?? true) return null;
    return results.first;
  }
}

class WherePhrase extends WhereCondition {
  final evaluatedField = null;
  final compare = Compare.exact;
  final value = null;

  /// Whether all [conditions] must evaulate to `true` for the query to return results.
  ///
  /// Defaults `false`.
  final bool required;

  final List<WhereCondition> conditions;

  /// A collection of conditions that are evaluated together.
  ///
  /// If mixing `required:true` `required:false` is necessary, use separate [WherePhrase]s.
  /// [WherePhrase]s can be mixed with [Where].
  ///
  /// Invalid:
  /// ```dart
  /// WherePhrase([
  ///   Where.exact('myField', true),
  ///   Or('myOtherField').isExactly(0),
  /// ])
  /// ```
  ///
  /// Valid:
  /// ```dart
  /// WherePhrase([
  ///   Where.exact('myField', true),
  ///   WherePhrase([
  ///     Or('myOtherField').isExactly(0),
  ///     Or('myOtherField').isExactly(1),
  ///   )]
  /// ])
  /// ```
  ///
// Why isn't WherePhrase a Where?
// The type hinting of distinct classes leads to a positive dev experience. When you type Where( you get a hint that the first arg is a column and the second arg is a value. When you type WherePhrase(, you get a hint that the first arg is a List.
//
// This also avoids putting too much logic into a single class by splitting it between two that should functionally be different. Determining if we're dealing with a Where or a WherePhrase also makes life easy on the translator.
//
// `required` also operates slightly differently for both. In where, it's the column. In WherePhrase, it's the whole chunk.
  const WherePhrase(
    this.conditions, {
    bool required,
  }) : this.required = required ?? false;

  /// Ensure that all nested conditions have a value
  static bool validateValuePresenceRecursively(WhereCondition condition) {
    if (condition.runtimeType == WherePhrase) {
      return condition.conditions.fold<bool>(true, (isValid, c) {
        if (!isValid) return false;
        return validateValuePresenceRecursively(c);
      });
    }

    return condition.value != null;
  }
}

/// Specify how to evalute the [value] against the [evaluatedField] in a [WhereCondition].
/// For size operators, a left side comparison is done.
///
/// For example, [lessThan] would produce `evaluatedField < value`
enum Compare {
  /// The query value matches the field value.
  exact,

  /// The field value is between the query values. The query value must be an ordered collection.
  between,

  /// The query value exists within the field value.
  contains,

  /// The query value is less than the field value.
  lessThan,

  /// The query value is less than or equal to the field value.
  lessThanOrEqualTo,

  /// The query value is greater than the field value.
  greaterThan,

  /// The query value is greater than or equal to the field value.
  greaterThanOrEqualTo,

  /// The query value does not match the field value.
  notEqual,
}
