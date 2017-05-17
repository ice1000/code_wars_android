import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class KeysAndValues {
  static const USER = "user_data.json";
  static const KATAS = "katas_data";
}

class Storage {
  static Future<File> openOrCreate(File file) async {
    return !(await file.exists()) ? file.create() : file;
  }

  static Future<File> getLocalFile(String fileName) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/$fileName');
  }

  static Future<String> readFile(String fileName) async =>
      (await openOrCreate(await getLocalFile(fileName))).readAsString();

  static writeFile(String fileName, String contents) async =>
      (await openOrCreate(await getLocalFile(fileName))).writeAsString(contents);
}
