///
/// Created by ice1000 on 2016/5/12
///
/// @author ice1000
///

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RefreshProgressDialog extends StatelessWidget {
  RefreshProgressDialog(this.background, {
    Key key,
    this.width,
    this.height,
  }) : super(key: key) {
    child = new RefreshProgressIndicator(backgroundColor: background);
  }

  final Color background;
  final int width;
  final int height;
  Widget child;

  Color _getColor(BuildContext context) {
    return Theme
        .of(context)
        .dialogBackgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 40.0, vertical: 24.0),
            child: new ConstrainedBox(
                constraints: new BoxConstraints(
                    minWidth: width.toDouble(),
                    minHeight: height.toDouble(),
                ),
                child: new Material(
                    elevation: 24.0,
                    color: _getColor(context),
                    type: MaterialType.card,
                    child: child
                )
            )
        )
    );
  }
}
