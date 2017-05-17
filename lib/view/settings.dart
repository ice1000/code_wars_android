import 'package:code_wars_android/code_wars/code_wars.dart';
import 'package:code_wars_android/code_wars/colors.dart';
import 'package:flutter/material.dart';

class SettingsActivity extends MaterialPageRoute<Null> {
  static const String _title = "Settings";
  CodeWarsUser _user;

  SettingsActivity() : super(builder: (BuildContext context) {
    _user =
    return new Scaffold(
        appBar: new AppBar(title: new Text(_title)),
        backgroundColor: CodeWarsColors.black,
        body: new ListView(primary: false, children: [
          new ListTile(title: new Text("Change user name"),
              subtitle: "",
              trailing: new IconButton(
                  icon: new Icon(Icons.edit), onPressed: () {
              }))
        ]));
  });
}
