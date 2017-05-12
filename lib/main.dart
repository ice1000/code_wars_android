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
        primarySwatch: Colors.grey,
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
  var _controller = new TextEditingController(text: "ice1000");

  void _onFabClick() {
    setState(() {
      get(CodeWarsAPI.getUser(user: _controller.text)).then((val) {
        showDialog(context: context, child: new Text(val.toString()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new EditableText(
            controller: _controller,
            focusNode: null,
            style: null,
            cursorColor: null),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _onFabClick,
        tooltip: 'Increment',
        child: new Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
