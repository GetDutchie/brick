import 'dart:convert';

import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:mockito/mockito.dart';

class MockLink extends Mock implements Link {
  @override
  Stream<Response> request(Request? request, [NextLink? forward]) => super.noSuchMethod(
        Invocation.method(#request, [request, forward]),
        returnValue: Stream.fromIterable(
          <Response>[],
        ),
      ) as Stream<Response>;
}

Link stubResponse(Map<String, dynamic> response, {List<String>? errors}) {
  final link = MockLink();

  when(
    link.request(any),
  ).thenAnswer(
    (_) => Stream.fromIterable([
      Response(
        data: response,
        response: {'body': jsonEncode(response)},
        errors: errors?.map((e) => GraphQLError(message: e)).toList().cast<GraphQLError>(),
      ),
    ]),
  );

  return link;
}
