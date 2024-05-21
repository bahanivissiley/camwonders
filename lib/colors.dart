import 'package:flutter/material.dart';
const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFFFFFFF),
  100: Color(0xFFFFFFFF),
  200: Color(0xFFFFFFFF),
  300: Color(0xFF64964D),
  400: Color(0xFF438026),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFF1E6100),
  700: Color(0xFF195600),
  800: Color(0xFF144C00),
  900: Color(0xFF0C3B00),
});
const int _primaryPrimaryValue = 0xFF226900;

const MaterialColor primaryAccent = MaterialColor(_primaryAccentValue, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_primaryAccentValue),
  400: Color(0xFF22FF0B),
  700: Color(0xFF16F100),
});
const int _primaryAccentValue = 0xFF50FF3E;