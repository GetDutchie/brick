import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/offline_first_with_graphql/offline_first_with_graphql.dart';

Future<Journal> _$JournalFromGraphQL(Map<String, dynamic> data,
    {required GraphQLProvider provider, OfflineFirstWithGraphQLRespository? respository}) async {
  return Journal(
      note: data['note'],
      createdDate: data['createdDate'],
      noteName: data['noteName'],
      subject: data['subject']);
}

Future<Map<String, dynamic>> _$JournalToGraphQL(Journal instance,
    {required GraphQLProvider provider, OfflineFirstWithGraphQLRespository? respository}) async {
  return {
    'note': instance.note,
    'createdDate': instance.createdDate,
    'noteName': instance.noteName,
    'subject': instance.subject
  };
}

class Journal extends GraphQLModel {
  final String note;
  final String createdDate;
  final String noteName;
  final String subject;

  Journal(
      {required this.note,
      required this.createdDate,
      required this.noteName,
      required this.subject});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
