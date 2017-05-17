import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class KeysAndValues {
  static const USER = "user_data";
  static const KATAS = "katas_data";
}

class Storage {
  Future<File> _getLocalFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/counter.txt');
  }
}
