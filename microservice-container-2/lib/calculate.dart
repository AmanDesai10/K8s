import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

Response calculateSum(String keyword, String fileContent, String fileName) {
  List<String> lines = fileContent.split("\n");
  int sum = 0;
  for (int i = 1; i < lines.length; i++) {
    List<String> line = lines[i].split(",");
    if (line[0] == keyword) {
      sum += int.parse(line[1]);
    }
  }
  print(sum);
  return Response.ok(jsonEncode({"file": fileName, "sum": sum}));
}

Response extractFileContent(dynamic jsonData) {
  File file = File("/AMAN_PV_dir/${jsonData["file"]}");
  String fileContent = file.readAsStringSync();

  return calculateSum(jsonData["product"], fileContent, jsonData["file"]);
}
