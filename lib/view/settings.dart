import 'package:code_wars_android/code_wars/colors.dart';
import 'package:flutter/material.dart';

class SettingsActivity extends MaterialPageRoute<Null> {
  static const String _title = "Settings";

  SettingsActivity() : super(builder: (BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(_title)),
        backgroundColor: CodeWarsColors.black,

    );
  });
}
