import 'dart:convert';
import 'package:code_wars_android/code_wars/code_wars.dart';
import 'package:code_wars_android/code_wars/colors.dart';
import 'package:code_wars_android/util/storage.dart';
import 'package:flutter/material.dart';

class SettingsActivity extends MaterialPageRoute<Null> {
  SettingsActivity()
      : super(builder: (BuildContext context) => new SettingsView());
}

class SettingsView extends StatefulWidget {
  static const String _title = "Settings";

  @override
  State<StatefulWidget> createState() => new SettingsState(_title);
}

// ignore: must_be_immutable
class SettingsState extends State<SettingsView> {
  CodeWarsUser _user;
  String _title = "Settings";
  Color textColor = CodeWarsColors.black.shade700;

  SettingsState(this._title);

  @override
  Widget build(BuildContext context) {
    Storage.readFile(KeysAndValues.USER)
      ..then((val) {
        setState(() {
          _user = new CodeWarsUser.fromJSON(new JsonDecoder(null).convert(val));
        });
      });

    return new Scaffold(
        appBar: new AppBar(title: new Text(_title)),
        backgroundColor: CodeWarsColors.black.shade200,
        body: new ListView(primary: false, children: [
          new ListTile(title: new Text("Change user name",
              style: new TextStyle(color: textColor)),
              subtitle: new Text(_user?.name ?? "Unknown",
                  style: new TextStyle(color: textColor)),
              trailing: new IconButton(
                  icon: new Icon(Icons.edit), onPressed: () {}))
        ]));
  }
}
