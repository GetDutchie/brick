import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_graphql/src/offline_first_with_graphql_repository.dart';
import 'package:gql_exec/gql_exec.dart';

/// Converts an `OfflineFirstPolicy` to a context object for later use in the request manager.
/// The request manager may choose to ignore the policy if the request is not a mutation.
class OfflineFirstGraphqlPolicy extends ContextEntry {
  /// [OfflineFirstWithGraphqlRepository.delete] invocations
  final OfflineFirstDeletePolicy? delete;

  @override
  List<dynamic> get fieldsForEquality => [delete, get, upsert];

  /// [OfflineFirstWithGraphqlRepository.get] invocations
  final OfflineFirstGetPolicy? get;

  /// [OfflineFirstWithGraphqlRepository.upsert] invocations
  final OfflineFirstUpsertPolicy? upsert;

  /// Converts an `OfflineFirstPolicy` to a context object for later use in the request manager.
  /// The request manager may choose to ignore the policy if the request is not a mutation.
  const OfflineFirstGraphqlPolicy({
    this.delete,
    this.get,
    this.upsert,
  });

  /// Serialize
  Map<String, dynamic> toJson() => {
        if (delete != null) 'delete': delete?.index,
        if (get != null) 'get': get?.index,
        if (upsert != null) 'upsert': upsert?.index,
      };
}
