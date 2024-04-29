import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;

class CustomValidator {
  Future<Response> run(dynamic jsonData) async {
    if (validateBodyFormat(jsonData)) {
      if (validateFileName(jsonData)) {
        return validateFileContentAndFileExistence(jsonData);
      } else {
        return Response.internalServerError(
            body: jsonEncode({"file": null, "error": "Invalid JSON input."}),
            headers: {"Content-Type": "application/json"});
      }
    } else {
      return Response.internalServerError(
          body: bodyInvalidFormat(),
          headers: {"Content-Type": "application/json"});
    }
  }

  bool validateBodyFormat(dynamic jsonData) {
    return (jsonData is Map &&
        jsonData.containsKey("file") &&
        jsonData.containsKey("product"));
  }

  bool validateFileName(dynamic jsonData) {
    return jsonData["file"] != null;
  }

  Future<Response> validateFileContentAndFileExistence(dynamic jsonData) async {
    File file = File("/AMAN_PV_dir/${jsonData["file"]}");
    if (file.existsSync()) {
      String fileContent = file.readAsStringSync();

      if (fileContent.contains(",") && fileContent.contains("\n")) {
        dynamic response = await http.post(
            Uri.parse(
                "http://summation-service.default.svc.cluster.local/calculate"),
            body: jsonEncode(
                {"file": jsonData["file"], "product": jsonData["product"]}));
        return Response.ok(response.body,
            headers: {"Content-Type": "application/json"});
      }

      return Response.internalServerError(
          body: jsonEncode({
            "file": jsonData["file"],
            "error": "Input file not in CSV format."
          }),
          headers: {"Content-Type": "application/json"});
    }
    return Response.internalServerError(
        body:
            jsonEncode({"file": jsonData["file"], "error": "File not found."}),
        headers: {"Content-Type": "application/json"});
  }
}

String bodyInvalidFormat() {
  return jsonEncode({
    "error": "Invalid format",
    "message":
        "The request body must be a JSON object with the following properties: file, product"
  });
}
