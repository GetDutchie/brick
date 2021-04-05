import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'dart:io';

void main() {
  var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(_echoRequest);

  io.serve(handler, 'localhost', 8080).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}

Future<shelf.Response> _echoRequest(shelf.Request request) async {
  final endpoints = ["customer", "customers", "pizza", "pizzas"];

  return await endpoints
      .fold(shelf.Response.notFound("Request ${request.url} does not match a known endpoint"),
          (acc, endpoint) async {
    final resp = await _jsonForRequest(request, endpoint);
    return shelf.Response.ok(resp, headers: {"Content-Type": "application/json"});
  });
}

Future<String?> _jsonForRequest(shelf.Request request, String fileName) async {
  if (!request.url.toString().startsWith(fileName)) return null;
  return await File("_api/$fileName.json").readAsString();
}
