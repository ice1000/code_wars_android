import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
/// Created by ice1000 on 2017/6/27
///
/// @author ice1000
///


class OnePageActivity extends MaterialPageRoute<Null> {
  OnePageActivity(Widget child) : super(builder: (BuildContext context) => new _OnePageView(child));
}

class _OnePageView extends StatefulWidget {
  final Widget child;

  _OnePageView(this.child);

  @override
  State<StatefulWidget> createState() => new _OnePageState(child);
}

class _OnePageState extends State<_OnePageView> {
  final Widget child;
  _OnePageState(this.child);

  @override
  Widget build(BuildContext context) => new Scaffold(body: child,);
}
