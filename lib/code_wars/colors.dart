///
/// Created by ice1000 on 2017/5/12
///
/// @author ice1000
///

import 'package:flutter/material.dart';

class CodeWarsColors {
  static const MaterialColor black = const MaterialColor(
    _codeWarsBlackPrimaryValue,
    const <int, Color>{
      50: const Color(0xFFC2C2C2),
      100: const Color(0xFFA2A2A2),
      200: const Color(0xFF828282),
      300: const Color(0xFF626262),
      400: const Color(0xFF424242),
      500: const Color(_codeWarsBlackPrimaryValue),
      600: const Color(0xFF262729),
      700: const Color(0xFF222222),
      800: const Color(0xFF1D1D1f),
      900: const Color(0xFF151515),
    },
  );
  static const _codeWarsBlackPrimaryValue = 0xFF303133;

  static const MaterialColor red = Colors.red;
}
