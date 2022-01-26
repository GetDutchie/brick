class GraphqlVariable {
  /// The `UpdatePersonInput` in `mutation UpdatePerson($input: UpdatePersonInput)`
  final String className;

  /// The `input` in `mutation UpdatePerson($input: UpdatePersonInput)`
  final String name;

  /// A `!` in `mutation UpdatePerson($input: UpdatePersonInput!)` indicates that the
  /// input value cannot be nullable.
  /// Defaults `false`.
  final bool nullable;

  const GraphqlVariable({
    required this.className,
    required this.name,
    this.nullable = false,
  });
}
