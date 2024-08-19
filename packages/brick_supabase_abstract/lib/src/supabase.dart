import 'package:brick_core/field_serializable.dart';

/// An annotation used to specify how a field is serialized for a [SupabaseAdapter].
/// Heavily inspired by [JsonKey](https://github.com/dart-lang/json_serializable/blob/master/json_annotation/lib/src/json_key.dart)
class Supabase implements FieldSerializable {
  /// The value to use if the source does not contain this key or if the
  /// value is `null`. **Only applicable during deserialization.**
  ///
  /// Must be a primitive type: `bool`, `DateTime`, `double`, `int`, `List`, `Map`,
  /// `Set`, or `String`. [defaultValue] must also match the field's `Type`.
  @override
  final String? defaultValue;

  /// By default, all enums from Supabase are assumed to be delivered as `int`. For APIs that
  /// deliver enums as `String` (e.g. `{"party", "baseball", ...}`). Works for Iterable and
  /// single field types of `enum`.
  ///
  /// The type of this field should be an enum. Defaults to `false`.
  @override
  final bool enumAsString;

  /// Specify the foreign key to use on the table when fetching for a remote association.
  ///
  /// For example, given the `orders` table has a `customer_id` column that associates
  /// the `customers` table, an `Order` class in Dart may look like:
  ///
  /// ```dart
  /// @SupabaseSerializeable(tableName: 'orders')
  /// class Order {
  ///   @Supabase(foreignKey: 'customer_id')
  ///   final Customer customer;
  /// }
  ///
  /// @SupabaseSerializeable(tableName: 'customers')
  /// class Customer {
  ///   final int id;
  /// }
  /// ```
  final String? foreignKey;

  @override
  final String? fromGenerator;

  @override
  final bool ignore;

  @override
  final bool ignoreFrom;

  @override
  final bool ignoreTo;

  /// This field reflects a unique index in the Supabase table, such as a primary key,
  /// most often `id`.
  ///
  /// Fields where `unique` is `true` will be used to target upserts and deletes.
  final bool unique;

  /// The key name to use when reading and writing values corresponding
  /// to the annotated field.
  ///
  /// Associations should not be annotated with `name`.
  ///
  /// If `null`, the snake case value of the field is used.
  @override
  final String? name;

  /// When `true`, `null` fields are handled gracefully when encoding from JSON.
  /// This indicates that the payload from Supabase could be `null` and is not related to
  /// Dart nullability. Defaults to `false`.
  @override
  final bool nullable;

  @override
  final String? toGenerator;

  /// Creates a new [Supabase] instance.
  ///
  /// Only required when the default behavior is not desired.
  const Supabase({
    this.defaultValue,
    bool? enumAsString,
    this.fromGenerator,
    this.foreignKey,
    bool? ignore,
    bool? ignoreFrom,
    bool? ignoreTo,
    bool? unique,
    this.name,
    bool? nullable,
    this.toGenerator,
  })  : enumAsString = enumAsString ?? false,
        ignore = ignore ?? false,
        ignoreFrom = ignoreFrom ?? false,
        ignoreTo = ignoreTo ?? false,
        unique = unique ?? false,
        nullable = nullable ?? false;

  /// An instance of [Supabase] with all fields set to their default values.
  static const defaults = Supabase();
}
