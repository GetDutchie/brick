/// Interface for other field-level annotations.
/// For example, `class Rest extends FieldSerializable {}`
abstract class FieldSerializable {
  /// The value to use if the source does not contain this key or if the
  /// value is `null`. **Only applicable during deserialization.**
  dynamic get defaultValue;

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
}
