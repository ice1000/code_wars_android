import 'dart:convert';
import 'package:code_wars_android/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:code_wars_android/code_wars/code_wars.dart';
import 'package:code_wars_android/code_wars/colors.dart';
import 'package:code_wars_android/util/util.dart';
import 'package:http/http.dart';


// ignore: must_be_immutable
class MainActivity extends StatelessWidget {
  var mainTitle = 'Code Wars';

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: mainTitle,
      theme: new ThemeData(primarySwatch: CodeWarsColors.black),
      home: new TabsFabDemo(mainTitle),
    );
  }
}

class _Page {
  _Page({
    this.displayWhenEmpty,
    this.icon,
    this.information,
    this.child,
    this.tabLabel
  });

  String displayWhenEmpty;
  final String tabLabel;
  final MaterialColor colors = CodeWarsColors.red;
  final IconData icon;
  final String information;
  Widget child;
  VoidCallback onClick;

  Color get labelColor => colors.shade500;

  bool get fabHere => null != icon;

  Color get fabColor => colors.shade700;

  Icon get createIcon => new Icon(icon);

  Key get fabKey => new ValueKey<Color>(fabColor);

  Widget get childWight =>
      child ?? new Card(
          color: CodeWarsColors.black.shade300,
          child: new Center(child: new Text(displayWhenEmpty,
              style: new TextStyle(color: labelColor, fontSize: 32.0),
              textAlign: TextAlign.center)));
}

class TabsFabDemo extends StatefulWidget {
  final String _title;

  TabsFabDemo(this._title);

  @override
  _TabsFabDemoState createState() => new _TabsFabDemoState(_title);
}

class _TabsFabDemoState extends State<TabsFabDemo>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Color _background = CodeWarsColors.black.shade200;
  final String _title;
  PageStorageBucket _storage;
  List<_Page> _allPages;
  _Page _friends;
  _Page _kata;
  _Page _me;

  _TabsFabDemoState(this._title);

  TabController _tabController;
  TextEditingController _usernameEditingController;
  CodeWarsUser _user;
  _Page _selectedPage;

  @override
  void initState() {
    super.initState();
    _storage = PageStorage.of(context);
    _usernameEditingController = new TextEditingController();
    _friends = new _Page(
      displayWhenEmpty: 'Friends',
      tabLabel: 'Friends',
      icon: Icons.add,
      information: "You can view your friends' information or "
          "add new friends in this page.",);
    _kata = new _Page(
      displayWhenEmpty: 'Kata',
      tabLabel: 'Kata',
      icon: Icons.add_box,
      information: "You can view or add katas here, and preview them.\n"
          "submitting is not supported ATM",);
    _me = new _Page(
      displayWhenEmpty: 'User not set yet.',
      tabLabel: 'Me',
      information: "Information about yourself on Code Wars.\n"
          "You can change your username.",);
    _allPages = <_Page>[_friends, _kata, _me];
    _tabController = new TabController(vsync: this, length: _allPages.length);
    _tabController.addListener(_handleTabSelection);
    _selectedPage = _me;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      _selectedPage = _allPages[_tabController.index];
    });
  }

  void _showExplanatoryText() {
    _scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
      return new Container(
          decoration: new BoxDecoration(
              border: new Border(top: new BorderSide(color: Theme
                  .of(context)
                  .dividerColor))),
          child: new Padding(
              padding: const EdgeInsets.all(32.0),
              child: new Text(_selectedPage.information, style: Theme
                  .of(context)
                  .textTheme
                  .subhead)));
    });
  }

  Widget buildTabView(_Page page) =>
      new Container(
          key: new ValueKey<String>(page.tabLabel),
          color: _background,
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 32.0),
          child: page.childWight);

  _performChangeUser(Map json) {
    _user = new CodeWarsUser();
    if (false == json['success']) {
      _me.displayWhenEmpty = json['reason'];
      _user = null;
    } else {
      _user.username = json['username'];
      _user.name = json['name'] ?? 'Unknown';
      _user.clan = json['clan'] ?? '';
      _user.honor = json['honor'];
      _user.leaderboardPosition = json['leaderboardPosition'];
      _user.skills = json['skills'];
      if (null == _user.skills || _user.skills.isEmpty) {
        _user.skills = const[" no skills found "];
      }
    }
    _storage.writeState(context, json, identifier: KeysAndValues.USER);
  }

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
              CodeWarsColors.black.shade100, width: 100, height: 100),
              barrierDismissible: false);
          get(CodeWarsAPI.getUser(_usernameEditingController.text))
            ..then((val) {
              setState(() {
                var json = new JsonDecoder(null).convert(val.body);
                _performChangeUser(json);
              });
              Navigator.pop(context);
            })
            ..timeout(new Duration(seconds: 10))
            ..catchError(() {
              setState(() {
                _me.displayWhenEmpty = "Connect time out";
                _user = null;
                Navigator.pop(context);
              });
            })
          ;
        }, child: new Text("OK")),
      ], title: new Text("Reset your username"),);
    showDialog(context: context, child: dialog);
  }

  @override
  Widget build(BuildContext context) {
    if (null != _user)
      _me.child = new Scrollbar(child: new ListView(
          padding: new EdgeInsets.symmetric(vertical: 0.0),
          primary: false,
          itemExtent: 30.0,
          children: [
            new ListTile(title: new Text(_user.name, style: new TextStyle(
                color: CodeWarsColors.white.shade200, fontSize: 32.0)),
                trailing: new Text("\n${_user.username}", style: new TextStyle(
                    color: CodeWarsColors.white.shade200, fontSize: 16.0))),
            new ListTile(
                title: new Text("\n${_user.clan}", style: new TextStyle(
                    color: CodeWarsColors.white.shade200, fontSize: 16.0))),
            const ListTile(),
            new ListTile(trailing: new Text("${_user.honor}",
                style: new TextStyle(
                    color: CodeWarsColors.red.shade400, fontSize: 22.0)),
                title: new Text("Honor", style: new TextStyle(
                    color: CodeWarsColors.red.shade400, fontSize: 20.0))),
            new ListTile(trailing: new Text("${_user.leaderboardPosition}",
                style: new TextStyle(
                    color: CodeWarsColors.red.shade400, fontSize: 22.0)),
                title: new Text("LeaderBoard Rank", style: new TextStyle(
                    color: CodeWarsColors.red.shade400, fontSize: 20.0))),
            const ListTile(),
            new ListTile(title: new Text("Skills:", style: new TextStyle(
                color: CodeWarsColors.white.shade200, fontSize: 24.0))),
            new ListTile(title: new Scrollbar(
                child: new ListView(scrollDirection: Axis.horizontal,
                    children: _user.skills.map((f) =>
                    new Card(elevation: 1.5,
                        color: CodeWarsColors.white.shade400,
                        child: new Text(" $f ", style: new TextStyle(
                            color: CodeWarsColors.red.shade500,
                            fontSize: 16.0)))).toList()))),
          ]));
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text(_title),
          actions: [
            new IconButton(
                icon: new Icon(Icons.edit), onPressed: _changeUserName),
            // settings
          ],
          bottom: new TabBar(
            controller: _tabController,
            tabs: _allPages.map((_Page page) => new Tab(text: page.tabLabel))
                .toList(),)),
      floatingActionButton: !_selectedPage.fabHere ? null
          : new FloatingActionButton(
          key: _selectedPage.fabKey,
          tooltip: 'Show explanation',
          backgroundColor: _selectedPage.fabColor,
          child: _selectedPage.createIcon,
          onPressed: _selectedPage.onClick ?? _showExplanatoryText
      ),
      body: new TabBarView(
          controller: _tabController,
          children: _allPages
              .map(buildTabView)
              .toList()
      ),
    );
  }
}