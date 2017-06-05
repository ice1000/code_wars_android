import 'dart:convert';

import 'package:code_wars_android/code_wars/code_wars.dart';
import 'package:code_wars_android/code_wars/colors.dart';
import 'package:code_wars_android/util/storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:code_wars_android/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class SettingsActivity extends MaterialPageRoute<Null> {
  SettingsActivity(CodeWarsUser user) :
        super(builder: (BuildContext context) => new SettingsView(user));
}

class SettingsView extends StatefulWidget {
  static const String _title = "Settings";
  final CodeWarsUser _user;

  SettingsView(this._user);

  @override
  State<StatefulWidget> createState() => new SettingsState(_title, _user);
}

// ignore: must_be_immutable
class SettingsState extends State<SettingsView> {
  CodeWarsUser _user;
  String _title = "Settings";
  Color _textColor = CodeWarsColors.notSoImportant.shade800;
  Color _titleColor = CodeWarsColors.notSoImportant.shade100;
  TextEditingController _usernameEditingController;

  SettingsState(this._title, this._user);

  _performChangeUser(String _json) {
    try {
      Map json = new JsonDecoder(null).convert(_json);
      var reason = json['reason'];
      _user = null != reason ? null : new CodeWarsUser.fromJson(json);
    } catch (e) {
      _json = CodeWarsAPI.getErrorWithReason("invalid");
    }
  }

  _pop() => Navigator.canPop(context) ? Navigator.pop(context) : null;

  _changeUserName() {
    var dialog = new SimpleDialog(
      contentPadding: new EdgeInsets.all(20.0),
      children: [
        new TextFormField(
            decoration: const InputDecoration(
                hintText: "Click OK to submit",
                labelText: "New user name"),
            maxLines: 1,
            controller: _usernameEditingController),
        new FlatButton(onPressed: () {
          Navigator.pop(context);
          showDialog(context: context, child: new RefreshProgressDialog(
              CodeWarsColors.main.shade100, width: 100, height: 100),
              barrierDismissible: false);
          get(CodeWarsAPI.getUser(_usernameEditingController.text))
            ..then((val) {
              setState(() => _performChangeUser(val.body));
              SharedPreferences.getInstance().then((sp) {
                sp.setString(DatabaseKeys.USER, val.body);
              });
              _pop();
            })
            ..timeout(new Duration(seconds: 10), onTimeout: () {
              SharedPreferences.getInstance().then((sp) {
                sp.setString(DatabaseKeys.USER, CodeWarsAPI
                    .getErrorWithReason("time out"));
              });
              setState(() {
                _user = null;
                _pop();
              });
            });
        }, child: new Text("OK",
            style: new TextStyle(color: _textColor))),
      ], title: new Text("Reset your username",
        style: new TextStyle(color: _textColor)),);
    showDialog(context: context, child: dialog);
  }


  @override
  void initState() {
    super.initState();
    _usernameEditingController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [
      new ListTile(
          title: new Text("Change user name",
              style: new TextStyle(
                  fontSize: 16.0,
                  color: _textColor)),
          subtitle: new Text(
              _user?.username ?? "Unknown",
              style: new TextStyle(
                  fontSize: 14.0,
                  color: _textColor)),
          dense: true,
          trailing: new IconButton(
              icon: new Icon(Icons.edit),
              onPressed: _changeUserName)),
      new ExpansionTile(
          title: new Text("App info",
              style: new TextStyle(
                  fontSize: 16.0,
                  color: _textColor)),
          children: [
            new ListTile(
                dense: true,
                title: new Text("Source on GitHub",
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: _textColor)),
                onTap: () => _viewWeb('https://github.com/ice1000/code_wars_android')),
            new ListTile(
                dense: true,
                title: new Text("License",
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: _textColor)),
                onTap: () {
                  showDialog(
                      context: context,
                      child: new SimpleDialog(
                          title: new Text(
                              "License",
                              style: new TextStyle(color: _textColor)),
                          contentPadding: new EdgeInsets.all(12.0),
                          children: [
                            new Text(
                                GPLv3,
                                style: new TextStyle(color: _textColor))
                          ]));
                }),
            new ListTile(
                dense: true,
                title: new Text("Open CodeWars",
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: _textColor)),
                onTap: () => _viewWeb('https://www.codewars.com/')),
          ])
    ];
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(
                _title,
                style: new TextStyle(
                    color: _titleColor))),
        backgroundColor: CodeWarsColors.main.shade50,
        body: new ListView(
            primary: false,
            children: list,
            shrinkWrap: true));
  }

  _viewWeb(String url) async {
    if (await canLaunch(url)) await launch(url);
  }
}
