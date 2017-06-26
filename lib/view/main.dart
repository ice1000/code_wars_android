import 'dart:convert';

import 'package:code_wars_android/code_wars/code_wars.dart';
import 'package:code_wars_android/code_wars/colors.dart';
import 'package:code_wars_android/util/storage.dart';
import 'package:code_wars_android/util/util.dart';
import 'package:code_wars_android/view/completed.dart';
import 'package:code_wars_android/view/settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class Application extends StatelessWidget {
  var mainTitle = 'Code Wars';

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: mainTitle,
      theme: new ThemeData(primarySwatch: CodeWarsColors.main),
      home: new _MainView(mainTitle),
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

class _MainView extends StatefulWidget {
  final String _title;

  _MainView(this._title);

  @override
  _MainActivity createState() => new _MainActivity(_title);
}

class _MainActivity extends State<_MainView>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final Color _background = CodeWarsColors.main.shade50;
  static final Color _textColor = CodeWarsColors.notSoImportant.shade600;
  static final Color _importantColor = CodeWarsColors.notSoImportant.shade800;
  final String _title;
  List<_Page> _allPages;
  TextEditingController _friendNameController;
  bool _isRefreshingNewFriend = false;
  _Page _friends;
  _Page _kata;
  _Page _me;
  TabController _tabController;
  CodeWarsUser _user;
  CodeWarsUser _refreshingFriend;
  List<CodeWarsUser> _friendUsers = [];
  _Page _selectedPage;

  _MainActivity(this._title);

  _changeTheBossOfThisGym() {
    SharedPreferences.getInstance().then((sp) {
      _performChangeUser(sp.getString(DatabaseKeys.USER) ??
          CodeWarsAPI.getErrorWithReason("not set"));
      Set<String> us = sp.getStringSet(DatabaseKeys.FRIENDS) ?? [];
      _performChangeFriends(us.map((s) => sp.getString(DatabaseKeys.friendData(s))).toList());
    });
  }

  _pop() => Navigator.canPop(context) ? Navigator.pop(context) : null;

  @override
  void initState() {
    super.initState();
    _changeTheBossOfThisGym();
    _friendNameController = new TextEditingController();
    _friends = new _Page(
      displayWhenEmpty: 'Friends',
      // 还有这种friend?
      tabLabel: 'Friends',
      information: "Add friend",);
    _kata = new _Page(
      displayWhenEmpty: 'Kata',
      tabLabel: 'Kata',
      information: "Refresh",);
    _me = new _Page(
      displayWhenEmpty: 'Go there ↗ to specify a user.',
      tabLabel: 'Me',
      icon: Icons.refresh,
      onClick: () {
        if (null != _user) {
          showDialog(context: context, child: new RefreshProgressDialog(
              CodeWarsColors.main.shade100, width: 100, height: 100),
              barrierDismissible: false);
          get(CodeWarsAPI.getUser(_user.username))
            ..then((val) {
              _performChangeUser(val.body);
              SharedPreferences.getInstance().then((sp) {
                sp.setString(DatabaseKeys.USER, val.body);
              });
              _pop();
            })
            ..timeout(new Duration(seconds: 10))
            ..catchError(() {
              SharedPreferences.getInstance().then((sp) {
                sp.setString(DatabaseKeys.USER, CodeWarsAPI
                    .getErrorWithReason("time out"));
              });
              setState(() => _user = null);
              _pop();
            });
        }
      },
      information: "Refresh",);
    _allPages = <_Page>[_friends, _kata, _me];
    _tabController = new TabController(vsync: this, length: _allPages.length);
    _tabController.addListener(_handleTabSelection);
    _selectedPage = _allPages.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendNameController.dispose();
    super.dispose();
  }

  _handleTabSelection() => setState(() => _selectedPage = _allPages[_tabController.index]);

  Widget buildTabView(_Page page) =>
      new Container(
          key: new ValueKey<String>(page.tabLabel), color: _background,
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 32.0),
          child: page.childWight);

  /// errors handled.
  /// please use [onError] to custom your error handle code
  CodeWarsUser _json2user(String _json, {onError: Function}) {
    try {
      Map json = new JsonDecoder(null).convert(_json);
      var reason = json['reason'];
      if (null != reason) {
        setState(() => onError(reason));
        return null;
      } else
        return new CodeWarsUser.fromJson(json);
    } catch (e) {
      setState(() => onError(e));
      return null;
    }
  }

  _performChangeUser(String _json) {
    CodeWarsUser user = _json2user(_json, onError: (msg) => _me.displayWhenEmpty = msg);
    showDialog(context: context, child: new Text(user.username));
    setState(() => _user = user);
  }

  _performChangeFriends(List<String> _allJson) {
    var all = _allJson
        .map(_json2user)
        .where((o) => null != o);
    setState(() => all.forEach(_friendUsers.add));
  }

  bool _addFriend(String _json) {
    CodeWarsUser friend = _json2user(_json);
    if (null != friend) {
      _friendUsers.add(friend);
      SharedPreferences.getInstance().then((sp) =>
          sp.setStringSet(DatabaseKeys.FRIENDS, _friendUsers.map((obj) => obj.username).toSet()));
      return true;
    }
    return false;
  }

  List<Widget> _getUserInfoView(CodeWarsUser _user) {
    return <Widget>[
      new ListTile(
          title: new Text(
              _user.name,
              style: new TextStyle(
                  color: _textColor,
                  fontSize: 32.0)),
          trailing: new Text(
              "\n${_user.username}",
              style: new TextStyle(
                  color: _textColor,
                  fontSize: 16.0))),
      new ListTile(
          title: new Text(
              "\n${_user.clan}",
              style: new TextStyle(
                  color: _textColor,
                  fontSize: 16.0))),
      const ListTile(),
      new ListTile(
          trailing: new Text(
              "${_user.honor}",
              style: new TextStyle(
                  color: _importantColor,
                  fontSize: 22.0)),
          title: new Text(
              "Honor",
              style: new TextStyle(
                  color: _importantColor,
                  fontSize: 20.0))),
      new ListTile(
          trailing: new Text(
              "${_user.leaderboardPosition}",
              style: new TextStyle(
                  color: _importantColor,
                  fontSize: 22.0)),
          title: new Text(
              "LeaderBoard Rank",
              style: new TextStyle(
                  color: _importantColor,
                  fontSize: 20.0))),
      const ListTile(),
      new ListTile(
          title: new Text("Overall",
              style: new TextStyle(
                  color: _textColor,
                  fontSize: 24.0))),
      new ListTile(
          title: new Text(
              "Score: ${_user.overall.score}",
              style: new TextStyle(
                  color: _importantColor,
                  fontSize: 20.0)),
          trailing: new Text(
              "<${_user.overall.name}>",
              style: new TextStyle(
                  color: _importantColor,
                  fontSize: 20.0)),
          dense: true),
      const ListTile(),
      new ListTile(
          title: new Text(
              "Skills:",
              style: new TextStyle(
                  color: _textColor,
                  fontSize: 24.0))),
      new ListTile(
          title: new ListView(
              scrollDirection: Axis.horizontal,
              children: _user.skills.map((f) =>
              new Card(
                  elevation: 1.5,
                  color: _textColor,
                  child: new Text(
                      " $f ",
                      style: new TextStyle(
                          color: _background,
                          fontSize: 16.0)))).toList())),
      const ListTile(),
      new ListTile(
          title: new Text(
              "Challenges",
              style: new TextStyle(
                  color: _textColor,
                  fontSize: 24.0))),
      new ListTile(
          trailing: new Text(
              "${_user.totalAuthored}",
              style: new TextStyle(
                  color: _importantColor,
                  fontSize: 20.0)),
          title: new Text(
              "Authored",
              style: new TextStyle(
                  color: _importantColor,
                  fontSize: 18.0))),
      new ListTile(
          trailing: new Text(
              "${_user.totalCompleted}",
              style: new TextStyle(
                  color: _importantColor,
                  fontSize: 20.0)),
          title: new Text(
              "Completed",
              style: new TextStyle(
                  color: _importantColor,
                  fontSize: 18.0))),
      const ListTile(),
      new ListTile(
          title: new Text(
              "Languages",
              style: new TextStyle(
                  color: _textColor,
                  fontSize: 24.0))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (null != _user) {
      List<Widget> list = _getUserInfoView(_user);
      _user.langsRank.forEach((rank) {
        list.add(new ListTile(
            dense: true,
            title: new Text(
                "${rank.lang}\n",
                style: new TextStyle(
                    color: _importantColor,
                    fontSize: 18.0)),
            trailing: new Text(
                "${rank.score} <${rank.name}>",
                style: new TextStyle(
                    color: _importantColor,
                    fontSize: 14.0))));
      });
      list.add(const ListTile());
      list.add(const ListTile());
      _me.child = new ListView(
          padding: new EdgeInsets.symmetric(vertical: 0.0),
          primary: false,
          itemExtent: 30.0,
          children: list);
      _kata.child = new Scrollbar(child: new ListView(
        primary: false,
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        children: new List.generate(_user.totalCompleted ~/ 200 + 1, (page) =>
        new ListTile(onTap: () {
          if (null != _user) {
            showDialog(context: context, child: new RefreshProgressDialog(
                CodeWarsColors.main.shade100, width: 100, height: 100),
                barrierDismissible: false);
            get(CodeWarsAPI.getCompletedKataPaginated(_user.username, page + 1))
              ..then((val) {
                _pop();
                Navigator.of(context).push(new CompletedActivity(val.body, page));
              })
              ..timeout(new Duration(seconds: 10))
              ..catchError(() => _pop());
          }
        }, title: new Text("Completed ${page * 200 + 1} ~ ${(page + 1) * 200}"))),
        shrinkWrap: true,
      ));
    }
    List<Widget> _friendsView = _friendUsers.map((user) =>
    new ExpansionTile(
      leading: new IconButton(
        icon: new Icon(_refreshingFriend == user ? Icons.adjust : Icons.refresh),
        onPressed: () {
          setState(() => _refreshingFriend = user);
          get(CodeWarsAPI.getUser(user.username))
            ..then((val) {
              int index = _friendUsers.indexOf(user);
              CodeWarsUser u = _json2user(val.body);
              setState(() {
                _friendUsers.removeAt(index);
                _friendUsers.insert(index, u);
                _refreshingFriend = null;
              });
              SharedPreferences.getInstance().then((sp) =>
                  sp.setString(DatabaseKeys.friendData(user.username), val.body));
            })
            ..timeout(new Duration(seconds: 10))
            ..catchError(() {
              _pop();
              setState(() => _refreshingFriend = null);
            });
        },),
      title: new ListTile(
        title: new Text(
          user.name,
          style: new TextStyle(
              color: _importantColor,
              fontSize: 20.0),),
        trailing: new Text("<${user.overall.name}>"),),
      children: <Widget>[
        new ListTile(
          title: new Text("Honor"),
          trailing: new Text("${user.honor}"),),
        new ListTile(
          title: new Text("Leaderboard Rank"),
          trailing: new Text("${user.leaderboardPosition}"),),
        new ListTile(
          title: new Text("Authored Kata"),
          trailing: new Text("${user.totalAuthored}"),),
        new ListTile(
          title: new Text("Completed Kata"),
          trailing: new Text("${user.totalCompleted}"),),
        new ListTile(title: new FlatButton(
            child: new Text(
              "Delete",
              style: new TextStyle(color: Colors.red),),
            onPressed: () {
              setState(() => _friendUsers.remove(user));
              SharedPreferences.getInstance().then((sp) =>
                  sp.setStringSet(DatabaseKeys.FRIENDS, _friendUsers.map((u) => u.username).toSet()));
            }),)
      ],)).toList();
    _friendsView.add(new ListTile(
      isThreeLine: true,
      dense: true,
      subtitle: const ListTile(),
      title: new TextFormField(
        maxLines: 1,
        controller: _friendNameController,
        decoration: const InputDecoration(
            hintText: "Friend's username",
            isDense: true,
            labelText: "Add new..."),),
      trailing: new IconButton(
        tooltip: "Add friend",
        icon: new Icon(_isRefreshingNewFriend ? Icons.adjust : Icons.done),
        onPressed: () {
          setState(() => _isRefreshingNewFriend = true);
          get(CodeWarsAPI.getUser(_friendNameController.text))
            ..then((val) {
              setState(() => _isRefreshingNewFriend = false);
              if (!_addFriend(val.body))
                showDialog(context: context, child: new SimpleDialog(
                  title: new Text("Error"),
                  children: <Widget>[
                    new Text("Sorry, user not found")
                  ],));
            })
            ..timeout(new Duration(seconds: 10))
            ..catchError(() {
              _pop();
              setState(() => _isRefreshingNewFriend = false);
            });
        },),));
    _friendsView.add(const ListTile());
    _friends.child = new ListView(
      primary: false,
      padding: new EdgeInsets.symmetric(vertical: 16.0),
      shrinkWrap: true,
      children: _friendsView,
    );
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text(_title),
          actions: [
            new IconButton(
                icon: new Icon(Icons.settings),
                onPressed: () =>
                    Navigator.of(context).push(new SettingsActivity(_user)).then((_) =>
                        setState(_changeTheBossOfThisGym))),
          ],
          bottom: new TabBar(
            controller: _tabController,
            tabs: _allPages.map((_Page page) => new Tab(text: page.tabLabel)).toList(),)),
      floatingActionButton: !_selectedPage.fabHere ? null
          : new FloatingActionButton(
          key: _selectedPage.fabKey,
          tooltip: _selectedPage.information,
          backgroundColor: _selectedPage.fabColor,
          child: _selectedPage.createIcon,
          onPressed: _selectedPage.onClick),
      body: new TabBarView(
          controller: _tabController,
          children: _allPages.map(buildTabView).toList()),);
  }
}
