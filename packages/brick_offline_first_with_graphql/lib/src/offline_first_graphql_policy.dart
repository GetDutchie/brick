import 'package:brick_offline_first/offline_first.dart';
import 'package:gql_exec/gql_exec.dart';

class OfflineFirstGraphqlPolicy extends ContextEntry {
  final OfflineFirstDeletePolicy? delete;

  @override
  List<dynamic> get fieldsForEquality => [delete, get, upsert];

  final OfflineFirstGetPolicy? get;

  final OfflineFirstUpsertPolicy? upsert;

  const OfflineFirstGraphqlPolicy({
    this.delete,
    this.get,
    this.upsert,
  });

  Map<String, dynamic> toJson() => {
        if (delete != null) 'delete': delete?.index,
        if (get != null) 'get': get?.index,
        if (upsert != null) 'upsert': upsert?.index,
      };
}
