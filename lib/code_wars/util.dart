///
/// Created by ice1000 on 2016/5/12
///
/// @author ice1000
///

import 'package:flutter/material.dart';

class BigText extends Text {
  BigText(String data, {textColor: Color}) : super(data, style: new TextStyle(
    fontSize: 24.0,
    color: textColor
  ));
}

