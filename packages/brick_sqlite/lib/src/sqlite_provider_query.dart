import 'package:brick_core/query.dart';
import 'package:brick_sqlite/src/sqlite_provider.dart';

class SqliteProviderQuery extends ProviderQuery<SqliteProvider> {
  final String? collate;

  final String? groupBy;

  final String? having;

  const SqliteProviderQuery({
    this.collate,
    this.groupBy,
    this.having,
  });

  @override
  Map<String, dynamic> toJson() => {
        if (collate != null) 'collate': collate,
        if (groupBy != null) 'groupBy': groupBy,
        if (having != null) 'having': having,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SqliteProviderQuery &&
          runtimeType == other.runtimeType &&
          collate == other.collate &&
          groupBy == other.groupBy &&
          having == other.having;

  @override
  int get hashCode => collate.hashCode ^ groupBy.hashCode ^ having.hashCode;
}
