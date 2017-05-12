import 'package:flutter/material.dart';

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
      theme: new ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: new TabsFabDemo(mainTitle),
    );
  }
}

class _Page {
  _Page({ this.label, this.colors, this.icon, this.information, this.child });

  final String label;
  final MaterialColor colors;
  final IconData icon;
  final String information;
  final Widget child;

  Color get labelColor =>
      null != colors ? colors.shade300 : Colors.grey.shade300;

  bool get fabHere => null != colors && null != icon;

  Color get fabColor => colors.shade200;

  Icon get createIcon => new Icon(icon);

  Key get fabKey => new ValueKey<Color>(fabColor);
}

final List<_Page> _allPages = <_Page>[
  new _Page(
      label: 'Friends',
      colors: Colors.blue,
      icon: Icons.add,
      information: "You can view your friends' information or "
          "add new friends in this page."
  ),
  new _Page(
      label: 'Kata',
      colors: Colors.red,
      icon: Icons.add_box,
      information: "You can view or add katas here, and preview them.\n"
          "you're not abled to submit ATM"
  ),
  new _Page(
      label: 'Me',
      colors: Colors.yellow,
      icon: Icons.edit,
      information: "Information about yourself.\n"
          "You can change your username."
  ),
];

class TabsFabDemo extends StatefulWidget {
  final String _title;

  TabsFabDemo(this._title);

  @override
  _TabsFabDemoState createState() => new _TabsFabDemoState(_title);
}

class _TabsFabDemoState extends State<TabsFabDemo>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final String _title;

  _TabsFabDemoState(this._title);

  TabController _controller;
  _Page _selectedPage;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(vsync: this, length: _allPages.length);
    _controller.addListener(_handleTabSelection);
    _selectedPage = _allPages[0];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      _selectedPage = _allPages[_controller.index];
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

  Widget buildTabView(_Page page) {
    return new Builder(
        builder: (BuildContext context) {
          return new Container(
              key: new ValueKey<String>(page.label),
              padding: const EdgeInsets.fromLTRB(48.0, 48.0, 48.0, 96.0),
              child: new Card(
                  child: new Center(
                      child: new Text(page.label,
                          style: new TextStyle(
                              color: page.labelColor,
                              fontSize: 32.0
                          ),
                          textAlign: TextAlign.center
                      )
                  )
              )
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text(_title),
          bottom: new TabBar(
            controller: _controller,
            tabs: _allPages.map((_Page page) =>
            new Tab(text: page.label)).toList(),
          )
      ),
      floatingActionButton: !_selectedPage.fabHere
          ? null
          : new FloatingActionButton(
          key: _selectedPage.fabKey,
          tooltip: 'Show explanation',
          backgroundColor: _selectedPage.fabColor,
          child: _selectedPage.createIcon,
          onPressed: _showExplanatoryText
      ),
      body: new TabBarView(
          controller: _controller,
          children: _allPages
              .map(buildTabView)
              .toList()
      ),
    );
  }
}
