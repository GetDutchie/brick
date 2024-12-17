import 'package:brick_core/core.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql/src/graphql_provider.dart';

/// This class should be subclassed for each model. For example:
///
/// ```dart
/// @GraphqlSerializable(
///   queryOperationTransformer: MyModelOperationTransformer.new,
/// )
/// class MyModel extends GraphqlModel {}
/// class MyModelOperationTransformer extends GraphqlQueryOperationTransformer<MyModel> {
///   final get = GraphqlOperation(
///     document: r'''
///       query GetPeople() {
///         getPerson() {}
///       }
///     '''
///   );
/// }
/// ```
abstract class GraphqlQueryOperationTransformer {
  /// The operation used for any destructive data operations that
  /// should use GraphQL's `mutation`.
  /// Only the header of the operation is required. For example
  /// ```graphql
  /// mutation DeletePerson($input: DeletePersonInput!) {
  ///   deletePerson(input: $input) {}
  /// }
  /// ```
  GraphqlOperation? get delete => null;

  /// The operation used for any single-fetch data operations that
  /// should use GraphQL's `query`.
  /// Only the header of the operation is required. For example
  /// ```graphql
  /// query GetPeople() {
  ///   getPerson() {}
  /// }
  /// ```
  GraphqlOperation? get get => null;

  /// The model being sent to the GraphQL server; this will
  /// only be non-null for [upsert] and [delete] operations.
  final Model? instance;

  /// A query provided with the provider or repository request.
  final Query? query;

  /// The operation used for any streaming data operations that
  /// should use GraphQL's `subscription`.
  /// Only the header of the operation is required. For example
  /// ```graphql
  /// subscription GetPerson($input: GetPersonInput!) {
  ///   getPerson(input: $input) {}
  /// }
  /// ```
  GraphqlOperation? get subscribe => null;

  /// The operation used for any updating or inserting data operations that
  /// should use GraphQL's `mutation`.
  /// Only the header of the operation is required. For example
  /// ```graphql
  /// query UpsertPerson($input: PersonInput!) {
  ///   upsertPerson(input: $input) {}
  /// }
  /// ```
  GraphqlOperation? get upsert => null;

  /// This class should be subclassed for each model. For example:
  ///
  /// ```dart
  /// @GraphqlSerializable(
  ///   queryOperationTransformer: MyModelOperationTransformer.new,
  /// )
  /// class MyModel extends GraphqlModel {}
  /// class MyModelOperationTransformer extends GraphqlQueryOperationTransformer<MyModel> {
  ///   final get = GraphqlOperation(
  ///     document: r'''
  ///       query GetPeople() {
  ///         getPerson() {}
  ///       }
  ///     '''
  ///   );
  /// }
  /// ```
  const GraphqlQueryOperationTransformer(this.query, this.instance);
}

/// A cohesive definition for [GraphqlQueryOperationTransformer]'s instance fields.
class GraphqlOperation {
  /// The GraphQL operation header. Fields will be used but will not be available
  /// to the Dart model.
  /// ```graphql
  /// query UpsertPerson($input: PersonInput!) {
  ///   upsertPerson(input: $input) {}
  /// }
  /// ```
  final String? document;

  /// Attached variables to the GraphQL operation.
  ///
  /// Values from this field will be nested within [GraphqlProvider]'s
  /// `variableNamespace` if it is defined.
  final Map<String, dynamic>? variables;

  /// A cohesive definition for [GraphqlQueryOperationTransformer]'s instance fields.
  const GraphqlOperation({this.document, this.variables});

  /// Deserialize
  factory GraphqlOperation.fromJson(Map<String, dynamic> data) =>
      GraphqlOperation(document: data['document'], variables: data['variables']);

  /// Serialize
  Map<String, dynamic> toJson() => {'document': document, 'variables': variables};
}
