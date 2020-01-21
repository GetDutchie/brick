import 'package:brick_core/field_serializable.dart';

/// An annotation used to specify how a field is serialized for a [RestAdapter].
/// Heavily inspired by [JsonKey](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_key.dart)
class Rest implements FieldSerializable {
  /// The value to use if the source does not contain this key or if the
  /// value is `null`. **Only applicable during deserialization.**
  ///
  /// Must be a primitive type: `bool`, `DateTime`, `double`, `int`, `List`, `Map`,
  /// `Set`, or `String`. [defaultValue] must also match the field's `Type`.
  @override
  final String defaultValue;

  /// By default, all enums from REST are assumed to be delivered as `int`. For APIs that
  /// deliver enums as `String` (e.g. `{"party", "baseball", ...}`). Works for Iterable and
  /// single field types of `enum`.
  ///
  /// The type of this field should be an enum. Defaults to `false`.
  final bool enumAsString;

  @override
  final String fromGenerator;

  /// `true` if the generator should ignore this field completely.
  /// When `true`, takes precedence over [ignoreFrom] and [ignoreTo]. Defaults to `false`.
  @override
  final bool ignore;

  /// `true` if this field should be ignored **only during** deserializization
  /// (when remote data is converted to Dart code). Defaults to `false`.
  final bool ignoreFrom;

  /// `true` if this field should be ignored **only during** serializization
  /// (when Dart code is sent to a remote source). Defaults to `false`.
  final bool ignoreTo;

  /// The key name to use when reading and writing values corresponding
  /// to the annotated field.
  ///
  /// Associations should not be annotated with `name`.
  ///
  /// If `null`, the snake case value of the field is used.
  @override
  final String name;

  /// When `true`, `null` fields are handled gracefully when encoding from JSON.
  /// Defaults to `false`.
  @override
  final bool nullable;

  @override
  final String toGenerator;

  /// Creates a new [Rest] instance.
  ///
  /// Only required when the default behavior is not desired.
  const Rest({
    this.defaultValue,
    this.enumAsString,
    this.fromGenerator,
    this.ignore,
    this.ignoreFrom,
    this.ignoreTo,
    this.name,
    this.nullable,
    this.toGenerator,
  });

  /// An instance of [Rest] with all fields set to their default values.
  static const defaults = Rest(
    enumAsString: false,
    ignore: false,
    ignoreFrom: false,
    ignoreTo: false,
    nullable: false,
  );
}
