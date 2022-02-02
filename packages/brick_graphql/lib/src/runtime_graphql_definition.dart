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

  /// The type accessed after the result is retrieved, **not** the GraphQL column type.
  /// In other words, the runtime type.
  final Type type;

  const RuntimeGraphqlDefinition({
    this.association = false,
    required this.documentNodeName,
    this.iterable = false,
    required this.type,
  });
}
