import 'package:brick_core/field_serializable.dart';

/// Low-level field config for the `OfflineFirst` domain.
class OfflineFirst {
  /// When `true` (the default), [where] will be used to fetch associations by their defined keys.
  /// This is useful when remote data is provided as an index instead of as fully-formed association
  /// data.
  ///
  /// For example, given the API: `{"classField" : true, "assoc": { "id": 12345 }}` and the `where`
  /// configuration `{'id' : "data['assoc']['id']"}`, a REST adapter would generate
  /// ```dart
  /// await repository?.getAssociation<Association>(
  ///   Query(where: [Where.exact('id', data['assoc']['id])], limit: 1)
  /// )
  /// ```
  ///
  /// When `false`, the output would generate assuming the full payload is present. Given the API
  /// `{"classField" : true, "assoc": { "id": 12345, "name": "class name" }}`, a REST adapter would
  /// generate
  /// ```dart
  /// await AssociationAdapter().fromRest(data['assoc'], provider: provider, repository: repository))
  /// ```
  final bool applyToRemoteDeserialization;

  /// This field is an association that is also an `OfflineFirstModel` and can be queried.
  /// The key is the association's SQLite column name and the value is the remote provider key with `data`.
  /// If the field type is an `Iterable`, the map requires the field value to be an `Iterable`.
  ///
  /// For example, given an API: `{"classField" : true, "assoc": { "id": 12345 }}`,
  /// ```dart
  /// @OfflineFirst(where: {'id' : "data['assoc']['id']"})
  /// final Assoc assoc;
  /// ```
  ///
  /// Or given a list: `{"classField" : true, "assoc": { "ids": [12345, 6789] }}`
  /// ```dart
  /// @OfflineFirst(where: {'id' : "data['assoc']['ids']"})
  /// final List<Assoc> assocs;
  /// ```
  ///
  /// If [where] is not defined for an association, Brick will attempt to instantiate the
  /// association from the data in the payload. When [where] is included, the field will
  /// not be generated for the serializer of the remote provider unless [FieldSerializable.toGenerator] is defined **or** only one pair is defined.
  final Map<String, String>? where;

  /// Annotates classes that require extra manipulation to map to the expected field type
  const OfflineFirst({
    this.applyToRemoteDeserialization = true,
    this.where,
  });

  ///
  static const defaults = OfflineFirst();
}
