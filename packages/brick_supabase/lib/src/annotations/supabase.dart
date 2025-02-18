import 'package:brick_core/field_serializable.dart';
import 'package:brick_supabase/src/supabase_adapter.dart';

/// An annotation used to specify how a field is serialized for a [SupabaseAdapter].
///
/// ```dart
/// class User extends OfflineFirstWithSupabaseModel{
///   // The foreign key is a relation to the `id` column of the Address table
///   @Supabase(foreignKey: 'address_id')
///   final Address address;
/// }
///
/// class Address extends OfflineFirstWithSupabaseModel{
///   final String id;
/// }
/// ```
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

  /// Specify a column for the ON clause in association queries.
  /// For example, `'customer_id'` in `customer:customers!customer_id(...)`.
  /// This is the model's column, not the association's column.
  ///
  /// This field must be specified if the current model uses
  /// [multiple foreign keys](https://supabase.com/docs/guides/database/joins-and-nesting?queryGroups=language&language=dart#specifying-the-on-clause-for-joins-with-multiple-foreign-keys).
  ///
  /// The remote column type can be different than the local Dart type. For example,
  /// `@Supabase(foreignKey: 'user_id')` that annotates `final User user` can be
  /// a Postgres string type.
  final String? foreignKey;

  @override
  final String? fromGenerator;

  @override
  final bool ignore;

  @override
  final bool ignoreFrom;

  @override
  final bool ignoreTo;

  /// Override the generated Supabase PostgREST query.
  /// This will replace **all contents** of the query, including any
  /// generated nested associations.
  ///
  /// Advanced use only. It is strongly recommended to allow Brick to
  /// generate the query at runtime based on the model definition.
  final String? query;

  /// This field reflects a unique index in the Supabase table, such as a primary key,
  /// most often `id`.
  ///
  /// Fields where `unique` is `true` will be used to target upserts and deletes.
  final bool unique;

  /// The key name to use when reading and writing values corresponding
  /// to the annotated field.
  ///
  /// **Do not use** `name` when annotating an association.
  /// Instead, use [foreignKey].
  ///
  /// If `null`, the renamed value of the field is used.
  @override
  final String? name;

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
    this.query,
    bool? unique,
    this.name,
    this.toGenerator,
  })  : enumAsString = enumAsString ?? false,
        ignore = ignore ?? false,
        ignoreFrom = ignoreFrom ?? false,
        ignoreTo = ignoreTo ?? false,
        unique = unique ?? false;

  /// An instance of [Supabase] with all fields set to their default values.
  static const defaults = Supabase();
}
