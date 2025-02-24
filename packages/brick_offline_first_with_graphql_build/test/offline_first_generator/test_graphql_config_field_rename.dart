import 'package:brick_core/field_rename.dart';
import 'package:brick_graphql/brick_graphql.dart' show GraphqlSerializable;
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';

const output = r'''
Future<GraphqlConfigNoRename> _$GraphqlConfigNoRenameFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return GraphqlConfigNoRename(someLongField: data['someLongField'] as int);
}

Future<Map<String, dynamic>> _$GraphqlConfigNoRenameToGraphql(
  GraphqlConfigNoRename instance, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'someLongField': instance.someLongField};
}

Future<GraphqlConfigNoRename> _$GraphqlConfigNoRenameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return GraphqlConfigNoRename(someLongField: data['some_long_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$GraphqlConfigNoRenameToSqlite(
  GraphqlConfigNoRename instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<GraphqlConfigSnakeRename> _$GraphqlConfigSnakeRenameFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return GraphqlConfigSnakeRename(
    someLongField: data['some_long_field'] as int,
  );
}

Future<Map<String, dynamic>> _$GraphqlConfigSnakeRenameToGraphql(
  GraphqlConfigSnakeRename instance, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<GraphqlConfigSnakeRename> _$GraphqlConfigSnakeRenameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return GraphqlConfigSnakeRename(someLongField: data['some_long_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$GraphqlConfigSnakeRenameToSqlite(
  GraphqlConfigSnakeRename instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<GraphqlConfigKebabRename> _$GraphqlConfigKebabRenameFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return GraphqlConfigKebabRename(
    someLongField: data['some-long-field'] as int,
  );
}

Future<Map<String, dynamic>> _$GraphqlConfigKebabRenameToGraphql(
  GraphqlConfigKebabRename instance, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some-long-field': instance.someLongField};
}

Future<GraphqlConfigKebabRename> _$GraphqlConfigKebabRenameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return GraphqlConfigKebabRename(someLongField: data['some_long_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$GraphqlConfigKebabRenameToSqlite(
  GraphqlConfigKebabRename instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}

Future<GraphqlConfigPascalRename> _$GraphqlConfigPascalRenameFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return GraphqlConfigPascalRename(someLongField: data['SomeLongField'] as int);
}

Future<Map<String, dynamic>> _$GraphqlConfigPascalRenameToGraphql(
  GraphqlConfigPascalRename instance, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'SomeLongField': instance.someLongField};
}

Future<GraphqlConfigPascalRename> _$GraphqlConfigPascalRenameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return GraphqlConfigPascalRename(
    someLongField: data['some_long_field'] as int,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$GraphqlConfigPascalRenameToSqlite(
  GraphqlConfigPascalRename instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'some_long_field': instance.someLongField};
}
''';

@ConnectOfflineFirstWithGraphql(
  // ignore: use_named_constants
  graphqlConfig: GraphqlSerializable(fieldRename: FieldRename.none),
)
class GraphqlConfigNoRename extends OfflineFirstModel {
  final int someLongField;

  GraphqlConfigNoRename(this.someLongField);
}

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(fieldRename: FieldRename.snake),
)
class GraphqlConfigSnakeRename extends OfflineFirstModel {
  final int someLongField;

  GraphqlConfigSnakeRename(this.someLongField);
}

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(fieldRename: FieldRename.kebab),
)
class GraphqlConfigKebabRename extends OfflineFirstModel {
  final int someLongField;

  GraphqlConfigKebabRename(this.someLongField);
}

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(fieldRename: FieldRename.pascal),
)
class GraphqlConfigPascalRename extends OfflineFirstModel {
  final int someLongField;

  GraphqlConfigPascalRename(this.someLongField);
}
