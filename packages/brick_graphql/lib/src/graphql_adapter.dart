import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:gql/ast.dart';

/// Constructors that convert app models to and from REST
abstract class GraphqlAdapter<_Model extends Model> implements Adapter<_Model> {
  /// The mutation used to remove data.
  DocumentNode? get defaultDeleteOperation => null;

  /// The query used to fetch multiple members.
  DocumentNode? get defaultQueryOperation => null;

  /// The query used to fetch a member.
  DocumentNode? get defaultQueryFilteredOperation => null;

  /// The subscription used to fetch all members.
  DocumentNode? get defaultSubscriptionOperation => null;

  /// The subscription used to fetch a member or specific members.
  DocumentNode? get defaultSubscriptionFilteredOperation => null;

  /// The mutation used to create or update a member.
  DocumentNode? get defaultUpsertOperation => null;

  Map<String, RuntimeGraphqlDefinition> get fieldsToGraphqlRuntimeDefinition;

  Future<_Model> fromGraphql(
    Map<String, dynamic> input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  });

  Future<Map<String, dynamic>> toGraphql(
    _Model input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  });

  /// Returns an enum value based on its string name. For example, given `'POST'`,
  /// and the enum `enum Methods { GET, POST, DELETE }`, `Methods.POST` is returned.
  static T? enumValueFromName<T>(Iterable<T> enumValues, String enumName) {
    return firstWhereOrNull(enumValues, (e) => e.toString().split('.').last == enumName);
  }

  /// After Dart 2.12, `firstWhere` can be a non-nullable return value. Instead of an extension,
  /// a predictable static method is used instead.
  ///
  /// From https://github.com/dart-lang/collection/blob/master/lib/src/iterable_extensions.dart
  /// to avoid importing a package for a single function.
  static T? firstWhereOrNull<T>(Iterable<T> values, bool Function(T item) test) {
    for (var item in values) {
      if (test(item)) return item;
    }
    return null;
  }
}
