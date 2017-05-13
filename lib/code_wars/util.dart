///
/// Created by ice1000 on 2016/5/12
///
/// @author ice1000
///

import 'package:flutter/material.dart';
import 'colors.dart';

class BigText extends Text {
  BigText(String data, {color: Color, size: double}) : super(data, style: new TextStyle(
    fontSize: size ?? 24.0,
    color: color ?? CodeWarsColors.red.shade400
  ));
}

