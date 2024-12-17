import 'package:brick_core/query.dart';
import 'package:brick_sqlite/src/sqlite_provider.dart';

/// [SqliteProvider]-specific options for a [Query]
class SqliteProviderQuery extends ProviderQuery<SqliteProvider> {
  /// Defines a value for `COLLATE`. Often this field is used for case insensitive
  /// queries where the value is `NOCASE`.
  final String? collate;

  /// Defines a value for `GROUP BY`.
  final String? groupBy;

  /// Defines a value for `HAVING`.
  final String? having;

  /// [SqliteProvider]-specific options for a [Query]
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
