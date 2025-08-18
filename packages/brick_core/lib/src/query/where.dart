import 'dart:convert';

import 'package:brick_core/core.dart';
import 'package:collection/collection.dart' show ListEquality;

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
  List<WhereCondition>? get conditions;

  /// The kind of comparison of the [evaluatedField] to the [value]. Defaults to [Compare.exact].
  /// It is the responsibility of the [Provider] to ignore or interpret the requested comparison.
  Compare get compare;

  /// Whether the condition(s) must evaluate to true. Defaults `true`.
  ///
  /// For example, `true` would translate to `AND` in SQL instead of `OR`.
  /// Some [Provider]s may ignore this field.
  bool get isRequired;

  /// The value to compare on the [evaluatedField].
  dynamic get value;

  /// Lower-level control over the value of a `Query#where` map.
  ///
  /// Example:
  /// ```dart
  /// Query(where: [
  ///   Where.exact('myField', 'must_match_this_value')
  ///   Where('myOtherField').contains('must_contain_this_value'),
  /// ])
  /// ```
  const WhereCondition();

  /// Deserialize from JSON
  factory WhereCondition.fromJson(Map<String, dynamic> data) {
    if (data['subclass'] == 'WherePhrase') {
      return WherePhrase(
        data['conditions'].map(WhereCondition.fromJson),
        isRequired: data['required'],
      );
    }

    return Where(
      data['evaluatedField'],
      value: data['value'],
      compare: Compare.values[data['compare']],
      isRequired: data['required'],
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'subclass': runtimeType.toString(),
        if (evaluatedField.isNotEmpty) 'evaluatedField': evaluatedField,
        'compare': Compare.values.indexOf(compare),
        if (conditions != null) 'conditions': conditions!.map((s) => s.toJson()).toList(),
        'required': isRequired,
        if (value != null) 'value': value,
      };

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhereCondition &&
          evaluatedField == other.evaluatedField &&
          compare == other.compare &&
          isRequired == other.isRequired &&
          _listEquality.equals(conditions, other.conditions) &&
          ((value is List && other.value is List)
              ? _listEquality.equals(value, other.value)
              : value == other.value);

  @override
  int get hashCode =>
      evaluatedField.hashCode ^
      compare.hashCode ^
      conditions.hashCode ^
      isRequired.hashCode ^
      value.hashCode;
}

/// A condition that evaluates to `true` in the [Provider] should return [Model](s).
///
/// This class should be exposed by the implemented [ModelRepository] and not imported from
/// this package as repositories may choose to extend or inhibit functionality.
class Where extends WhereCondition {
  @override
  final String evaluatedField;

  @override
  final Compare compare;

  @override
  final List<WhereCondition>? conditions;

  @override
  final bool isRequired;

  @override
  final dynamic value;

  /// Default values for [Where]
  static const defaults = Where('');

  /// A condition that evaluates to `true` in the [Provider] should return [Model](s).
  ///
  /// This class should be exposed by the implemented [ModelRepository] and not imported from
  /// this package as repositories may choose to extend or inhibit functionality.
  const Where(
    this.evaluatedField, {
    this.value,
    Compare? compare,
    bool? isRequired,
  })  : isRequired = isRequired ?? true,
        compare = compare ?? Compare.exact,
        conditions = null;

  /// A condition written with brevity. [isRequired] defaults `true`.
  const Where.exact(this.evaluatedField, this.value, {this.isRequired = true})
      : compare = Compare.exact,
        conditions = null;

  /// Convenience function to create a [Where] with [Compare.exact].
  Where isExactly(dynamic value) =>
      Where(evaluatedField, value: value, compare: Compare.exact, isRequired: isRequired);

  /// Convenience function to create a [Where] with [Compare.between].
  Where isBetween(dynamic value1, dynamic value2) {
    assert(value1.runtimeType == value2.runtimeType, 'Comparison values must be the same type');
    return Where(
      evaluatedField,
      value: [value1, value2],
      compare: Compare.between,
      isRequired: isRequired,
    );
  }

  /// Convenience function to create a [Where] with [Compare.contains].
  Where contains(dynamic value) =>
      Where(evaluatedField, value: value, compare: Compare.contains, isRequired: isRequired);

  /// Convenience function to create a [Where] with [Compare.doesNotContain].
  Where doesNotContain(dynamic value) =>
      Where(evaluatedField, value: value, compare: Compare.doesNotContain, isRequired: isRequired);

  /// Convenience function to create a [Where] with [Compare.lessThan].
  Where isLessThan(dynamic value) =>
      Where(evaluatedField, value: value, compare: Compare.lessThan, isRequired: isRequired);

  /// Convenience function to create a [Where] with [Compare.lessThanOrEqualTo].
  Where isLessThanOrEqualTo(dynamic value) => Where(
        evaluatedField,
        value: value,
        compare: Compare.lessThanOrEqualTo,
        isRequired: isRequired,
      );

  /// Convenience function to create a [Where] with [Compare.greaterThan].
  Where isGreaterThan(dynamic value) =>
      Where(evaluatedField, value: value, compare: Compare.greaterThan, isRequired: isRequired);

  /// Convenience function to create a [Where] with [Compare.greaterThanOrEqualTo].
  Where isGreaterThanOrEqualTo(dynamic value) => Where(
        evaluatedField,
        value: value,
        compare: Compare.greaterThanOrEqualTo,
        isRequired: isRequired,
      );

  /// Convenience function to create a [Where] with [Compare.notEqual].
  Where isNot(dynamic value) =>
      Where(evaluatedField, value: value, compare: Compare.notEqual, isRequired: isRequired);

  /// Convenience function to create a [Where] with [Compare.inIterable].
  Where isIn(Iterable<dynamic> values) =>
      Where(evaluatedField, value: values, compare: Compare.inIterable, isRequired: isRequired);

  /// Recursively find conditions that evaluate a specific field. A field is a member on a model,
  /// such as `myUserId` in `final String myUserId`.
  /// If the use case for the field only requires one result, say `id` or `primaryKey`,
  /// [firstByField] may be more useful.
  static List<WhereCondition> byField(String fieldName, List<WhereCondition>? conditions) {
    final flattenedConditions = <WhereCondition>[];

    /// recursively flatten all nested conditions
    void expandConditions(WhereCondition condition) {
      if (condition.conditions == null || condition.conditions!.isEmpty) {
        flattenedConditions.add(condition);
      } else {
        condition.conditions?.forEach(expandConditions);
      }
    }

    conditions?.forEach(expandConditions);

    return flattenedConditions.where((c) => c.evaluatedField == fieldName).toList();
  }

  /// Find the first occurrance of a condition that evaluates a specific field
  /// For all conditions, use [byField].
  static WhereCondition? firstByField(String fieldName, List<WhereCondition>? conditions) {
    final results = byField(fieldName, conditions);
    return results.isEmpty ? null : results.first;
  }
}

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
class WherePhrase extends WhereCondition {
  @override
  String get evaluatedField => '';

  @override
  Compare get compare => Compare.exact;

  @override
  dynamic get value => null;

  /// Whether all [conditions] must evaulate to `true` for the query to return results.
  ///
  /// Defaults `false`.
  @override
  final bool isRequired;

  @override
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
    bool? isRequired,
  }) : isRequired = isRequired ?? false;
}

/// Specify how to evalute the [WhereCondition.value] against the [WhereCondition.evaluatedField] in a [WhereCondition].
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

  /// The query value does not exist within the field value.
  doesNotContain,

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

  /// The field value is in the query value iterable.
  inIterable,
}
