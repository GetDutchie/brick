import 'package:brick_core/field_serializable.dart';

import 'package:brick_sqlite_abstract/src/db/migration.dart' show Column;
export 'package:brick_sqlite_abstract/src/db/migration.dart' show Column;

/// An annotation used to specify how a field is serialized.
/// Heavily inspired by [JsonKey](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_key.dart)
class Sqlite implements FieldSerializable {
  /// In very exceptional circumstance, the SQLite column type can be declared.
  ///
  /// Leaving this field `null` will allow Brick to infer the column type from the
  /// Type argument. This will not create foreign keys or associations.
  ///
  /// Advanced use only.
  final Column columnType;

  @override
  final String defaultValue;

  @override
  final String fromGenerator;

  @override
  final bool ignore;

  /// Create an `INDEX` on a single column. A `UNIQUE` index will be created when
  /// [unique] is `true`. When [unique] is `true` and [index] is absent or `false`, an
  /// index is not created.
  ///
  /// Iterable associations are automatically indexed through a generated joins table.
  /// [index] declared on these fields will be ignored.
  ///
  /// Defaults `false`.
  final bool index;

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

  /// When true, deletion of the referenced record by [foreignKeyColumn] on the [foreignTableName]
  /// this record. For example, if the foreign table is "departments" and the local table
  /// is "employees," whenever that department is deleted, "employee"
  /// will be deleted. Defaults `false`.
  ///
  /// This value is only applicable when decorating fields that are **single associations**
  /// (e.g. `final SqliteModel otherSqliteModel`). It is otherwise ignored.
  final bool onDeleteCascade;

  /// When true, deletion of a parent will set this table's referencing column to the default,
  /// usually `NULL` unless otherwise declared. Defaults `false`.
  ///
  /// This value is only applicable when decorating fields that are **single associations**
  /// (e.g. `final SqliteModel otherSqliteModel`). It is otherwise ignored.
  final bool onDeleteSetDefault;

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
  ///
  /// To index this column, [index] needs to be `true`. Indices **are not** automatically
  /// created for [unique] columns.
  final bool unique;

  /// Creates a new [Sqlite] instance.
  ///
  /// Only required when the default behavior is not desired.
  const Sqlite({
    this.columnType,
    this.defaultValue,
    this.fromGenerator,
    this.ignore,
    this.index,
    this.name,
    this.nullable,
    this.onDeleteCascade,
    this.onDeleteSetDefault,
    this.toGenerator,
    this.unique,
  });

  /// An instance of [Sqlite] with all fields set to their default
  /// values.
  static const defaults = Sqlite(
    ignore: false,
    index: false,
    nullable: true,
    onDeleteCascade: false,
    onDeleteSetDefault: false,
    unique: false,
  );
}
