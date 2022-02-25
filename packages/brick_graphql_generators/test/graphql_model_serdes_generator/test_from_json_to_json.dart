import 'package:brick_graphql/graphql.dart';

final output = r'''
Future<ToFromJson> _$ToFromJsonFromGraphql(Map<String, dynamic> data,
    {required GraphqlProvider provider,
    GraphqlFirstRepository? repository}) async {
  return ToFromJson(
      assoc: data['assoc'] != null
          ? ToFromJsonAssoc.fromJson(data['assoc'] as String)
          : null);
}

Future<Map<String, dynamic>> _$ToFromJsonToGraphql(ToFromJson instance,
    {required GraphqlProvider provider,
    GraphqlFirstRepository? repository}) async {
  return {'assoc': instance.assoc?.toJson()};
}
''';

class ToFromJsonAssoc {
  final int? integer;

  ToFromJsonAssoc({
    this.integer,
  });

  String toJson() => integer.toString();

  factory ToFromJsonAssoc.fromJson(String data) => ToFromJsonAssoc(integer: int.tryParse(data));
}

@GraphqlSerializable()
class ToFromJson {
  final ToFromJsonAssoc? assoc;

  ToFromJson({
    this.assoc,
  });
}
