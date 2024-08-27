// ignore_for_file: constant_identifier_names

/// Values for the automatic field renaming behavior for [FieldSerializable].
///
/// Heavily borrowed/inspired by [JsonSerializable](https://github.com/dart-lang/json_serializable/blob/a581e5cc9ee25bf4ad61e8f825a311289ade905c/json_serializable/lib/src/json_key_utils.dart#L164-L179)
enum FieldRename {
  /// Leave fields unchanged
  none,

  /// Encodes field name from `snakeCase` to `snake_case`.
  snake,

  /// Encodes field name from `kebabCase` to `kebab-case`.
  kebab,

  /// Capitalizes first letter of field name
  pascal,
}

/// Interface for other field-level annotations.
/// For example, `class Rest extends FieldSerializable {}`
abstract class FieldSerializable {
  /// The value to use if the source's value is `null`.
  /// This is often directly injected to the adapter, and wrapping is required for strings.
  /// (e.g. `defaultValue: "'Missing Last Name'"`)
  ///
  /// This value is usually only applied during deserialization.
  String? get defaultValue;

  /// By default, all enums are assumed to be delivered as `int`.
  /// However, this requires order to be maintained; additionally some providers
  /// deliver enums as `String` (e.g. `{"party", "baseball", ...}`). This field value should apply to Iterable and single field types of `enum`.
  ///
  /// The type of this field should be an enum. Defaults to `false`.
  bool get enumAsString;

  /// Manipulates output for the field in the deserialize generator.
  /// The instance's field name is automatically defined. While the build method is ultimately
  /// responsible for how the output is applied, it is most often directly injected as the
  /// value of the field in the deserialize adapter.
  ///
  /// `data` and `provider` is available as the deserialized version of the model.
  ///
  /// Placeholders can be used in the value of this field.
  String? get fromGenerator;

  /// `true` if the generator should ignore this field completely.
  /// When `true`, takes precedence over [ignoreFrom] and [ignoreTo]. Defaults to `false`.
  bool get ignore;

  /// `true` if this field should be ignored **only during** deserializization
  /// (when remote data is converted to Dart code). Defaults to `false`.
  bool get ignoreFrom;

  /// `true` if this field should be ignored **only during** serializization
  /// (when Dart code is sent to a remote source). Defaults to `false`.
  bool get ignoreTo;

  /// The key name to use when reading and writing values corresponding
  /// to the annotated field.
  String? get name;

  /// When `true`, `null` fields are handled gracefully when serializing and deserializing.
  /// For Dart >=2.12, the member type must also be nullable (i.e. `bool?`).
  bool get nullable;

  /// Manipulates output for the field in the serialize generator.
  /// The serializing key is defined from [name] or the default naming of the field. While the build method is ultimately
  /// responsible for how the output is applied, it is most often directly injected as the
  /// value of the field in the serialize adapter.
  ///
  /// `instance` and `provider` is available as the invoking model.
  ///
  /// Placeholders can be used in the value of this field.
  String? get toGenerator;

  /// Placeholder. Replaces with name (e.g. `@Rest(name:)` or `@Sqlite(name:)`).
  /// Defaults to field name after any applicable renaming transforms.
  static const ANNOTATED_NAME_VARIABLE = '%ANNOTATED_NAME%';

  /// Placeholder. Replaces with `data['annotated_name']` per `@Rest(name:)` or `@Sqlite(name:)`.
  /// Only valuable for `from` generators.
  static const DATA_PROPERTY_VARIABLE = '%DATA_PROPERTY%';

  /// Placeholder. Replaces with field name (`instance.myField` in `final String myField`).
  /// Only valuable for `to` generators.
  static const INSTANCE_PROPERTY_VARIABLE = '%INSTANCE_PROPERTY%';
}
