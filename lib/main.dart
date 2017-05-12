import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'code_wars.dart';

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
        primarySwatch: Colors.amber,
      ),
      home: new MyHomePage(title: mainTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String user = "ice1000";
  TextEditingController _controller;

  _MyHomePageState() {
    _controller = new TextEditingController(text: "ice1000");
  }

  void _onFabClick() {
    setState
      (() {
      read(CodeWarsAPI.getUser(user: _controller.text)).then((val) {
        print(val.toString());
        showDialog(
          context: context,
          child: new AlertDialog(
            content: new Text(val.toString()),
            title: new Text("user info: ${_controller.text}"),
          ),);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
        children: [
          new Text("username:", softWrap: true),
          new TextField(
            maxLines: 1,
            controller: _controller,
            autofocus: true,
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _onFabClick,
        tooltip: 'Search',
        child: new Icon(Icons.search),
      ),
    );
  }
}
