/// Interface for other field-level annotations.
/// For example, `class Rest extends FieldSerializable {}`
abstract class FieldSerializable {
  /// The value to use if the source's value is `null`.
  /// This is often directly injected to the adapter, and wrapping is required for strings.
  /// (e.g. `defaultValue: "'Missing Last Name'"`)
  ///
  /// This value is usually only applied during deserialization.
  String get defaultValue;

  /// Manipulates output for the field in the deserialize generator.
  /// The instance's field name is automatically defined. While the build method is ultimately
  /// responsible for how the output is applied, it is most often directly injected as the
  /// value of the field in the deserialize adapter.
  ///
  /// `data` and `provider` is available as the deserialized version of the model.
  ///
  /// Placeholders can be used in the value of this field.
  String get fromGenerator;

  /// `true` if the generator should ignore this field completely.
  bool get ignore;

  /// The key name to use when reading and writing values corresponding
  /// to the annotated field.
  String get name;

  /// When `true`, `null` fields are handled gracefully when serializing and deserializing.
  bool get nullable;

  /// Manipulates output for the field in the serialize generator.
  /// The serializing key is defined from [name] or the default naming of the field. While the build method is ultimately
  /// responsible for how the output is applied, it is most often directly injected as the
  /// value of the field in the serialize adapter.
  ///
  /// `instance` and `provider` is available as the invoking model.
  ///
  /// Placeholders can be used in the value of this field.
  String get toGenerator;

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
