import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

void main() {
  final handler =
      const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(_echoRequest);

  io.serve(handler, 'localhost', 8080).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}

Future<shelf.Response> _echoRequest(shelf.Request request) async {
  final endpoints = ['customers', 'customer', 'pizzas', 'pizza'];

  for (final endpoint in endpoints) {
    if (request.url.toString().startsWith(endpoint)) {
      final resp = await File('_api/$endpoint.json').readAsString();
      return shelf.Response.ok(resp, headers: {'Content-Type': 'application/json'});
    }
  }

  return shelf.Response.notFound('Request ${request.url} does not match a known endpoint');
}
