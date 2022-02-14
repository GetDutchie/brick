import 'package:brick_offline_first/offline_first.dart';
import 'package:gql_exec/gql_exec.dart';

class OfflineFirstGraphqlPolicy extends ContextEntry {
  final OfflineFirstDeletePolicy? delete;
  final OfflineFirstGetPolicy? get;
  final OfflineFirstUpsertPolicy? upsert;

  const OfflineFirstGraphqlPolicy({
    this.delete,
    this.get,
    this.upsert,
  });

  @override
  List<dynamic> get fieldsForEquality => [delete, get, upsert];
}
