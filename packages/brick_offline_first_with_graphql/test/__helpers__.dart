import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:mockito/mockito.dart';

Link stubGraphqlLink(
  Map<String, dynamic> response, {
  List<String>? errors,

  /// Mirrors GraphQL's typical data structure - the function name as the key - that
  /// wraps the result data
  bool wrapInTopLevelKey = true,
}) {
  final link = MockLink();

  if (wrapInTopLevelKey) {
    response = {'result': response};
  }

  when(
    link.request(any),
  ).thenAnswer(
    (_) => Stream.fromIterable([
      Response(
        data: response,
        errors: errors?.map((e) => GraphQLError(message: e)).toList().cast<GraphQLError>(),
        context: const Context(),
      ),
    ]),
  );

  return link;
}

Stream<Response> stubGraphqResult(Map<String, dynamic> response, List<String>? errors) {
  return Stream.fromIterable([
    Response(
      data: response,
      errors: errors?.map((e) => GraphQLError(message: e)).toList().cast<GraphQLError>(),
    ),
  ]);
}

class MockLink extends Mock implements Link {
  @override
  Stream<Response> request(Request? request, [NextLink? forward]) => super.noSuchMethod(
        Invocation.method(#request, [request, forward]),
        returnValue: Stream.fromIterable(
          <Response>[],
        ),
      ) as Stream<Response>;
}
