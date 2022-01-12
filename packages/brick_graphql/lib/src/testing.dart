import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

class StubFromGraphQL extends Fake implements Client {
  final Map<String, dynamic> mockedResult;
  final int mockedStatus;

  StubFromGraphQL({
    required this.mockedResult,
    this.mockedStatus = 200,
  });

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return Future<StreamedResponse>.value(
      StreamedResponse(
        Stream.value(utf8.encode(jsonEncode(mockedResult))),
        mockedStatus,
      ),
    );
  }
}
