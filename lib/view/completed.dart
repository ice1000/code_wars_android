import 'dart:convert';

import 'package:code_wars_android/code_wars/code_wars.dart';
import 'package:code_wars_android/code_wars/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
/// Created by ice1000 on 2017/6/2
///
/// @author ice1000
///

class CompletedActivity extends MaterialPageRoute<Null> {
  CompletedActivity(String data, int page) : super(
      builder: (BuildContext context) => new _CompletedView(data, page));
}

class _CompletedView extends StatefulWidget {
  final String _data;
  final int _page;

  _CompletedView(this._data, this._page);

  @override
  State<StatefulWidget> createState() =>
      new _CompletedState("Completed Katas Page $_page", _data, _page);
}

class _CompletedState extends State<_CompletedView> {
  final String _title;
  final String _data;
  final int _page;
  static final Color _titleColor = CodeWarsColors.notSoImportant.shade100;
  static final Color _textColor = CodeWarsColors.notSoImportant.shade600;
  static final Color _importantColor = CodeWarsColors.notSoImportant.shade800;
  List<KataCompleted> _completed;

  _CompletedState(this._title, this._data, this._page);

  @override
  void initState() {
    super.initState();
    try {
      Map json = new JsonDecoder(null).convert(_data);
      var reason = json['reason'];
      _completed = null != reason ? null : KataCompleted.fromJson(json);
    } catch (e) {
      _completed = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget view;
    if (null != _completed) {
      var list = <Widget>[];
      _completed.forEach((kata) {
        list.add(new ExpansionTile(
            title: new Text(kata.name,
                style: new TextStyle(fontSize: 20.0, color: _textColor)),
            children: [
              new ListTile(
                  dense: true,
                  isThreeLine: true,
                  subtitle: new Text(kata.slug,
                      style: new TextStyle(
                          fontSize: 13.0, color: _importantColor)),
                  title: new Text(kata.fullName,
                      style: new TextStyle(
                          fontSize: 16.0, color: _importantColor))),
//              new ListTile(
//                  dense: true,
//                  title: new Text(
//                      "Kata id: ${kata.id}",
//                      style: new TextStyle(
//                          fontSize: 16.0,
//                          color: _importantColor))),
              new ListTile(
                  isThreeLine: true,
                  dense: true,
                  subtitle: new Text(kata.completedLanguages.last,
                      style: new TextStyle(
                          fontSize: 14.0, color: _importantColor)),
                  title: new Text(kata.completedAt,
                      style: new TextStyle(
                          fontSize: 16.0, color: _importantColor))),
            ]));
      });
      view = new Scrollbar(
          child: new ListView(
            primary: false,
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            children: list,
            shrinkWrap: true,
          ));
    }
    return new Scaffold(
        appBar: new AppBar(title: new Text(_title, style: new TextStyle(color: _titleColor))),
        body: view ?? new Center(child: new Text("Error", style: new TextStyle(fontSize: 30.0, color: _titleColor))));
  }
}
