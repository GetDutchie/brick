import 'package:brick_core/field_serializable.dart';

/// An annotation used to specify how a field is serialized.
/// Heavily inspired by [JsonKey](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_key.dart)
class Sqlite implements FieldSerializable {
  @override
  final String defaultValue;

  @override
  final String fromGenerator;

  @override
  final bool ignore;

  /// The column name to use when reading and writing values corresponding
  /// to the annotated fields.
  ///
  /// Associations will not respect `name`.
  ///
  /// If `null`, the snake case value of the field is used.
  @override
  final String name;

  /// When `false`, the column will be inserted as `NOT NULL` and a value will be required in
  /// subsequent operations. Takes precedence over [SqliteSerializable]'s `#nullable`.
  /// Defaults to `true`.
  @override
  final bool nullable;

  /// When true, deletion of a row within this model's table will delete all
  /// referencing children records. Defaults `false`.
  ///
  /// This value is only applicable when decorating fields that are **single associations**
  /// (e.g. `final SqliteModel otherSqliteModel`). It is otherwise ignored.
  final bool onDeleteCascade;

  /// Manipulates output for the field in the SqliteSerializeGenerator
  /// The serializing key is defined from [Sqlite] or the default naming of the field.
  ///
  /// `instance` and `provider` is available as the invoking model.
  ///
  /// Placeholders can be used in the value of this field.
  @override
  final String toGenerator;

  /// When `true`, the column will be inserted with a `UNIQUE` constraint. Unique columns will
  /// also be listed in the adapter for querying if implemented by the invoking provider.
  /// Defaults to `false`. Does not apply to associations.
  final bool unique;

  /// Creates a new [Sqlite] instance.
  ///
  /// Only required when the default behavior is not desired.
  const Sqlite({
    this.defaultValue,
    this.fromGenerator,
    this.ignore,
    this.name,
    this.nullable,
    this.onDeleteCascade,
    this.toGenerator,
    this.unique,
  });

  /// An instance of [Sqlite] with all fields set to their default
  /// values.
  static const defaults = Sqlite(
    ignore: false,
    nullable: true,
    onDeleteCascade: false,
    unique: false,
  );
}
