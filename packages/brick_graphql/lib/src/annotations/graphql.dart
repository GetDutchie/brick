import 'package:brick_core/field_serializable.dart';

/// An annotation used to specify how a field is serialized for a `GraphqlAdapter`.
/// Heavily inspired by [JsonKey](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_key.dart)
class Graphql implements FieldSerializable {
  @override
  final String? defaultValue;

  @override
  final bool enumAsString;

  @override
  final String? fromGenerator;

  @override
  final bool ignore;

  @override
  final bool ignoreFrom;

  @override
  final bool ignoreTo;

  /// The key name to use when reading and writing values corresponding
  /// to the annotated field.
  ///
  /// Associations should not be annotated with `name`.
  ///
  /// If `null`, the snake case value of the field is used.
  @override
  final String? name;

  /// Supply subfields that should be requested from the server.
  ///
  /// When blank, if the annotated field is not a Dart primitive, the class will be crawled
  /// and its fields generated in the adapter.
  ///
  /// A supplied value will override the generated fields.
  final Map<String, Map<String, dynamic>>? subfields;

  @override
  final String? toGenerator;

  /// Creates a new [Graphql] instance.
  ///
  /// Only required when the default behavior is not desired.
  const Graphql({
    this.defaultValue,
    bool? enumAsString,
    this.fromGenerator,
    bool? ignore,
    bool? ignoreFrom,
    bool? ignoreTo,
    this.name,
    this.subfields,
    this.toGenerator,
  })  : enumAsString = enumAsString ?? false,
        ignore = ignore ?? false,
        ignoreFrom = ignoreFrom ?? false,
        ignoreTo = ignoreTo ?? false;

  /// An instance of [Graphql] with all fields set to their default values.
  static const defaults = Graphql();
}
