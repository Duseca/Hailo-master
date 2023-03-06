import 'dart:ui';
import 'package:flutter/material.dart';

class ColorConstant {
  static Color cyan30033 = fromHex('#3349ddc4');

  static Color black900B2 = fromHex('#b2000000');

  static Color gray50 = fromHex('#fafafa');

  static Color teal200 = fromHex('#85cdc0');

  static Color teal300 = fromHex('#38c0a9');

  static Color black900 = fromHex('#000000');

  static Color teal800 = fromHex('#0f6657');

  static Color cyan30019 = fromHex('#1949ddc4');

  static Color gray9000f = fromHex('#0f111111');

  static Color gray402 = fromHex('#c6c6c6');

  static Color gray600 = fromHex('#707070');

  static Color gray303 = fromHex('#e5e5e5');

  static Color gray403 = fromHex('#c4c4c4');

  static Color gray400 = fromHex('#b6b6b6');

  static Color gray301 = fromHex('#e3e3e3');

  static Color gray202 = fromHex('#e8e8e8');

  static Color gray500 = fromHex('#979797');

  static Color gray302 = fromHex('#e0e0e0');

  static Color gray401 = fromHex('#bfbfbf');

  static Color redA100 = fromHex('#ff7991');

  static Color gray404 = fromHex('#c2c2c2');

  static Color gray405 = fromHex('#c0c0c0');

  static Color bluegray100 = fromHex('#d1d5db');

  static Color redA10033 = fromHex('#33ff7991');

  static Color gray200 = fromHex('#e7e7e7');

  static Color gray101 = fromHex('#f7f7f7');

  static Color yellowA700 = fromHex('#ffd603');

  static Color gray300 = fromHex('#e6e6e6');

  static Color gray201 = fromHex('#ececec');

  static Color gray102 = fromHex('#f5f5f5');

  static Color gray100 = fromHex('#f2f2f2');

  static Color bluegray900 = fromHex('#333333');

  static Color cyan300 = fromHex('#49ddc4');

  static Color black90099 = fromHex('#99000000');

  static Color bluegray401 = fromHex('#8a8a8a');

  static Color bluegray400 = fromHex('#888888');

  static Color bluegray101 = fromHex('#d8d8d8');

  static Color whiteA700 = fromHex('#ffffff');

  static Color cyan301 = fromHex('#48d7bf');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
