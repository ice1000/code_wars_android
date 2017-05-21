import 'dart:convert';

import 'package:code_wars_android/code_wars/code_wars.dart';
import 'package:code_wars_android/code_wars/colors.dart';
import 'package:code_wars_android/util/storage.dart';
import 'package:code_wars_android/util/util.dart';
import 'package:code_wars_android/view/settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class MyApplication extends StatelessWidget {
  var mainTitle = 'Code Wars';

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: mainTitle,
      theme: new ThemeData(primarySwatch: CodeWarsColors.main),
      home: new MainActivity(mainTitle),
    );
  }
}

class _Page {
  _Page({
    this.displayWhenEmpty,
    this.icon,
    this.information,
    this.child,
    this.tabLabel,
    this.onClick
  });

  String displayWhenEmpty;
  final String tabLabel;
  final MaterialColor colors = CodeWarsColors.important;
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
          color: CodeWarsColors.main.shade300,
          child: new Center(child: new Text(displayWhenEmpty,
              style: new TextStyle(color: labelColor, fontSize: 32.0),
              textAlign: TextAlign.center)));
}

class MainActivity extends StatefulWidget {
  final String _title;

  MainActivity(this._title);

  @override
  _MainActivityState createState() => new _MainActivityState(_title);
}

class _MainActivityState extends State<MainActivity>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Color _background = CodeWarsColors.main.shade50;
  final Color _textColor = CodeWarsColors.notSoImportant.shade600;
  final Color _importantColor = CodeWarsColors.notSoImportant.shade800;
  final String _title;
  List<_Page> _allPages;
  _Page _friends;
  _Page _kata;
  _Page _me;

  _MainActivityState(this._title);

  TabController _tabController;
  CodeWarsUser _user;
  _Page _selectedPage;

  _changeAh() {
    SharedPreferences.getInstance().then((sp) {
      setState(() =>
          _performChangeUser(sp.getString(DatabaseKeys.USER) ??
              CodeWarsAPI.getErrorWithReason("not set")));
    });
  }

  @override
  void initState() {
    super.initState();
    _changeAh();
    _friends = new _Page(
      displayWhenEmpty: 'Friends', // 还有这种friend?
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
      icon: Icons.refresh,
      onClick: () {
        if (null != _user) {
          showDialog(context: context, child: new RefreshProgressDialog(
              CodeWarsColors.main.shade100, width: 100, height: 100),
              barrierDismissible: false);
          get(CodeWarsAPI.getUser(_user.username))
            ..then((val) {
              setState(() => _performChangeUser(val.body));
              Navigator.pop(context);
            })
            ..timeout(new Duration(seconds: 10))
            ..catchError(() {
              SharedPreferences.getInstance().then((sp) {
                sp.setString(DatabaseKeys.USER, CodeWarsAPI
                    .getErrorWithReason("time out"));
              });
              setState(() {
                _user = null;
                Navigator.pop(context);
              });
            });
        }
      },
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

  _performChangeUser(String _json) {
    Map json = new JsonDecoder(null).convert(_json);
    var reason = json['reason'];
    if (null != reason) {
      _me.displayWhenEmpty = reason;
      _user = null;
    } else
      _user = new CodeWarsUser.fromJSON(json);
    SharedPreferences.getInstance().then((sp) {
      sp.setString(DatabaseKeys.USER, _json);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (null != _user)
      _me.child = new Scrollbar(child: new ListView(
          padding: new EdgeInsets.symmetric(vertical: 0.0),
          primary: false, itemExtent: 30.0, children: [
        new ListTile(title: new Text(_user.name, style: new TextStyle(
            color: _textColor, fontSize: 32.0)),
            trailing: new Text("\n${_user.username}", style: new TextStyle(
                color: _textColor, fontSize: 16.0))),
        new ListTile(
            title: new Text("\n${_user.clan}", style: new TextStyle(
                color: _textColor, fontSize: 16.0))),
        const ListTile(),
        new ListTile(trailing: new Text("${_user.honor}",
            style: new TextStyle(color: _importantColor, fontSize: 22.0)),
            title: new Text("Honor", style: new TextStyle(
                color: _importantColor, fontSize: 20.0))),
        new ListTile(trailing: new Text("${_user.leaderboardPosition}",
            style: new TextStyle(color: _importantColor, fontSize: 22.0)),
            title: new Text("LeaderBoard Rank", style: new TextStyle(
                color: _importantColor, fontSize: 20.0))),
        const ListTile(),
        new ListTile(title: new Text("Skills:", style: new TextStyle(
            color: _textColor, fontSize: 24.0))),
        new ListTile(title: new ListView(scrollDirection: Axis.horizontal,
            children: _user.skills.map((f) =>
            new Card(elevation: 1.5, color: _textColor,
                child: new Text(" $f ", style: new TextStyle(
                    color: _background, fontSize: 16.0)))).toList())),
        const ListTile(),
        new ListTile(title: new Text("Challenges", style: new TextStyle(
            color: _textColor, fontSize: 24.0))),
        new ListTile(trailing: new Text("${_user.totalAuthored}",
            style: new TextStyle(color: _importantColor, fontSize: 20.0)),
            title: new Text("Authored", style: new TextStyle(
                color: _importantColor, fontSize: 18.0))),
        new ListTile(trailing: new Text("${_user.totalCompleted}",
            style: new TextStyle(color: _importantColor, fontSize: 20.0)),
            title: new Text("Completed", style: new TextStyle(
                color: _importantColor, fontSize: 18.0))),
        const ListTile(),
        new ListTile(title: new Text("Languages", style: new TextStyle(
            color: _textColor, fontSize: 24.0))),
        new ListView.builder(itemBuilder: (context, id) {
          return new Card()
        }, itemCount: _user.ranks.length)
      ]));
//    _kata.child = new Scrollbar(child: new ListView());
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text(_title),
          actions: [
            new IconButton(icon: new Icon(Icons.settings), onPressed: () {
              Navigator.of(context).push(new SettingsActivity()).then((_) {
                setState(_changeAh);
              });
            }),
            new IconButton(icon: new Icon(Icons.bug_report), onPressed: () {
              _performChangeUser("""{
  "username": "ice1000",
  "name": "千里冰封",
  "honor": 935,
  "clan": "Gensokyo",
  "leaderboardPosition": 4552,
  "skills": [
    "haskell",
    "cross dress",
    "sell moe"
  ],
  "ranks": {
    "overall": {
      "rank": -4,
      "name": "4 kyu",
      "color": "blue",
      "score": 1296
    },
    "languages": {
      "java": {
        "rank": -8,
        "name": "8 kyu",
        "color": "white",
        "score": 2
      },
      "dart": {
        "rank": -8,
        "name": "8 kyu",
        "color": "white",
        "score": 3
      },
      "haskell": {
        "rank": -4,
        "name": "4 kyu",
        "color": "blue",
        "score": 1291
      }
    }
  },
  "codeChallenges": {
    "totalAuthored": 0,
    "totalCompleted": 89
  }
}""");
            }),
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
          onPressed: _selectedPage.onClick ?? _showExplanatoryText),
      body: new TabBarView(
          controller: _tabController,
          children: _allPages
              .map(buildTabView)
              .toList()),);
  }
}
