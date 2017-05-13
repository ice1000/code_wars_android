import 'dart:convert';
import 'package:flutter/material.dart';
import 'code_wars/code_wars.dart';
import 'code_wars/colors.dart';
import 'package:code_wars_android/util/util.dart';
import 'package:http/http.dart';

void main() {
  runApp(new MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
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
  _Page({ this.label, this.icon, this.information, this.child });

  final String label;
  final MaterialColor colors = CodeWarsColors.red;
  final IconData icon;
  final String information;
  Widget child;
  dynamic onClick;

  Color get labelColor => colors.shade500;

  bool get fabHere => null != icon;

  Color get fabColor => colors.shade700;

  Icon get createIcon => new Icon(icon);

  Key get fabKey => new ValueKey<Color>(fabColor);

  Widget get childWight =>
      child ?? new Card(
          color: CodeWarsColors.black.shade300,
          child: new Center(
              child: new Text(label,
                  style: new TextStyle(color: labelColor, fontSize: 32.0),
                  textAlign: TextAlign.center
              )
          )
      );
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
  List<_Page> _allPages;
  _Page _friends;
  _Page _kata;
  _Page _me;

  _TabsFabDemoState(this._title);

  TabController _tabController;
  TextEditingController _usernameEditingController;
  CodeWarsUser _user = new CodeWarsUser.empty();
  _Page _selectedPage;

  @override
  void initState() {
    super.initState();
    _usernameEditingController = new TextEditingController();
    _friends = new _Page(
      label: 'Friends',
      icon: Icons.add,
      information: "You can view your friends' information or "
          "add new friends in this page.",
    );
    _kata = new _Page(
      label: 'Kata',
      icon: Icons.add_box,
      information: "You can view or add katas here, and preview them.\n"
          "submitting is not supported ATM",
    );
    _me = new _Page(
      label: 'Me',
      icon: Icons.edit,
      information: "Information about yourself on Code Wars.\n"
          "You can change your username.",
    );
    _allPages = <_Page>[_friends, _kata, _me];
    _me.onClick = () {
      var dialog = new SimpleDialog(
        contentPadding: new EdgeInsets.all(20.0),
        children: [
          new TextField(controller: _usernameEditingController),
          new FlatButton(onPressed: () {
            Navigator.pop(context);
            showDialog(context: context, child: new RefreshProgressDialog(
                CodeWarsColors.black.shade100, width: 100, height: 100));
            get(CodeWarsAPI.getUser(_usernameEditingController.text))
                .then((val) {
              setState(() {
                var json = new JsonDecoder(null).convert(val.body);
                _user.username = json['username'];
                _user.name = json['name'];
                _user.honor = json['honor'];
                _user.leaderboardPosition = json['leaderboardPosition'];
                _user.skills = json['skills'];
              });
              Navigator.pop(context);
            });
          }, child: new Text("OK")),
        ], title: new Text("Reset your username"),
      );
      showDialog(context: context, child: dialog);
    };
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
                  .dividerColor
              ))
          ),
          child: new Padding(
              padding: const EdgeInsets.all(32.0),
              child: new Text(_selectedPage.information, style: Theme
                  .of(context)
                  .textTheme
                  .subhead
              )
          )
      );
    });
  }

  Widget buildTabView(_Page page) =>
      new Container(
          key: new ValueKey<String>(page.label),
          color: _background,
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 32.0),
          child: page.childWight
      );

  @override
  Widget build(BuildContext context) {
    _me.child = new Column(
        children: [
          new Text("User Name: ${_user.username}", style: new TextStyle(
              color: CodeWarsColors.red.shade400, fontSize: 24.0)),
          new Text("Nick Name: ${_user.name}", style: new TextStyle(
              color: CodeWarsColors.red.shade400, fontSize: 24.0)),
          new Text("Honor: ${_user.honor}", style: new TextStyle(
              color: CodeWarsColors.red.shade400, fontSize: 24.0)),
          new Text("User Rank: ${_user.leaderboardPosition}", style:
          new TextStyle(color: CodeWarsColors.red.shade400, fontSize: 24.0)),
          new Text("Skills: ${_user.skills.toString()}", style: new TextStyle(
              color: CodeWarsColors.red.shade400, fontSize: 24.0)),
        ]);
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text(_title),
          bottom: new TabBar(
            controller: _tabController,
            tabs: _allPages
                .map((_Page page) => new Tab(text: page.label))
                .toList(),
          )
      ),
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
