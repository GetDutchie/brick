/// Used to define types in [GraphqlAdapter#fieldsToGraphqlRuntimeDefinition]. The build runner package
/// extracts types and associations that would've been otherwise inaccessible at runtime.
class RuntimeGraphqlDefinition {
  /// Whether this column relates to another GraphqlModel
  /// This is true for `Iterable<GraphqlModel>` and `GraphqlModel`. Defaults to `false`.
  final bool association;

  /// The GraphQL document field node, **not** the field name.
  final String documentNodeName;

  /// Whether this column is any subset `Iterable` (e.g. `List`, `Set`).
  /// Defaults to `false`.
  final bool iterable;

  /// For fields that are not strictly associations but have nested attributes,
  /// [subfields] needs to be defined for the GraphQL query to resolve.
  final Map<String, Map<String, dynamic>> subfields;

  /// The type accessed after the result is retrieved, **not** the GraphQL type.
  /// In other words, the runtime type.
  final Type type;

  /// Used to define types in [GraphqlAdapter#fieldsToGraphqlRuntimeDefinition]. The build runner package
  /// extracts types and associations that would've been otherwise inaccessible at runtime.
  const RuntimeGraphqlDefinition({
    this.association = false,
    required this.documentNodeName,
    this.iterable = false,
    this.subfields = const <String, Map<String, dynamic>>{},
    required this.type,
  });
}
