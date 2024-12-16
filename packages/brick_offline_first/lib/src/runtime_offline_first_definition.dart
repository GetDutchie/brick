/// Used to define types in [OfflineFirstAdapter#fieldsToOfflineFirstRuntimeDefinition]. The build runner package
/// extracts types and associations that would've been otherwise inaccessible at runtime.
class RuntimeOfflineFirstDefinition {
  /// The mappings declared by the `where` property in the
  /// `OfflineFirst` annotation
  final Map<String, String> where;

  /// Used to define types in [OfflineFirstAdapter#fieldsToOfflineFirstRuntimeDefinition]. The build runner package
  /// extracts types and associations that would've been otherwise inaccessible at runtime.
  const RuntimeOfflineFirstDefinition({
    required this.where,
  });
}
