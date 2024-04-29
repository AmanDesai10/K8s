import 'dart:convert';
import 'dart:io';

import 'package:b00965752_container_1/validate.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  const PORT = 6000;

  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_postRequestHandler);

  // Start the server
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

        return CustomValidator().run(jsonData);
      } catch (e) {
        return Response.internalServerError(
            body: 'Error processing POST request');
      }
    } else if (request.url.path == 'store-file') {
      String requestBody = await request.readAsString();
      dynamic jsonData = jsonDecode(requestBody);
      try {
        if (jsonData is Map &&
            jsonData.containsKey("file") &&
            jsonData.containsKey("data")) {
          if (jsonData["file"] == null) {
            return Response.internalServerError(
                body:
                    jsonEncode({"file": null, "error": "Invalid JSON input."}));
          }

          File file = File("/AMAN_PV_dir/${jsonData["file"]}");

          file.writeAsStringSync(jsonData["data"]);
          return Response.ok(
              jsonEncode({"file": jsonData["file"], "message": "Success."}));
        }
        return Response.internalServerError(
            body: jsonEncode({"file": null, "error": "Invalid JSON input."}));
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({
          "file": jsonData["file"],
          "error": "Error while storing the file to the storage.",
        }));
      }
    } else {
      return Response.notFound('Route Not found');
    }
  } else {
    return Response.badRequest(
        body: jsonEncode({'error': 'Only POST requests are accepted'}));
  }
}
