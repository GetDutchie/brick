import 'package:brick_core/field_rename.dart';
import 'package:brick_core/query.dart';
import 'package:brick_rest/src/rest_model.dart';
import 'package:brick_rest/src/rest_request_transformer.dart';

/// An annotation used to specify a class to generate code for.
///
/// Creates a serialize/deserialize function for JSON.
///
/// Heavily borrowed/inspired by [JsonSerializable](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_serializable.dart)
class RestSerializable {
  /// Defines the automatic naming strategy when converting class field names
  /// into JSON map keys.
  ///
  /// The value for `@Rest(name:)` will override this convention.
  final FieldRename fieldRename;

  /// When `true` (the default), `null` fields are handled gracefully when decoding `null`
  /// and nonexistent values from JSON. This indicates that the fields from REST could be `null`
  /// and is not related to Dart nullability.
  ///
  /// Setting to `false` eliminates `null` verification in the generated code,
  /// which reduces the code size. Errors may be thrown at runtime if `null`
  /// values are encountered, but the original class should also implement
  /// `null` runtime validation if it's critical. Defaults to `false`.
  final bool nullable;

  /// The interface used to determine the request to send to remote. This class
  /// will be accessed for all provider and repository operations.
  ///
  /// Implementing classes of [RestRequestTransformer] must be a `const`
  /// constructor. For simplicity, the default constructor tearoff can be provided
  /// as a value (`requestTransformer: MyTransformer.new`).
  final RestRequestTransformer Function(Query?, RestModel?)? requestTransformer;

  /// Creates a new [RestSerializable] instance.
  const RestSerializable({
    FieldRename? fieldRename,
    bool? nullable,
    this.requestTransformer,
  })  : fieldRename = fieldRename ?? FieldRename.snake,
        nullable = nullable ?? false;

  /// An instance of [RestSerializable] with all fields set to their default
  /// values.
  static const defaults = RestSerializable();
}
