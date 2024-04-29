import 'dart:convert';
import 'dart:io';

import 'package:b00965752_container_2/calculate.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  const PORT = 8080;

  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_postRequestHandler);

  var server = await shelf_io.serve(handler, InternetAddress.anyIPv4, PORT);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<Response> _postRequestHandler(Request request) async {
  if (request.method == 'POST') {
    print(request.url.path);

    if (request.url.path == 'calculate') {
      try {
        String requestBody = await request.readAsString();
        dynamic jsonData = jsonDecode(requestBody);

        return extractFileContent(jsonData);
      } catch (e) {
        return Response.internalServerError(
            body: 'Error processing POST request');
      }
    } else {
      return Response.notFound('Route Not found');
    }
  } else {
    return Response.badRequest(
        body: jsonEncode({'error': 'Only POST requests are accepted'}));
  }
}
