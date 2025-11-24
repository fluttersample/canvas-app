// A minimal single-file Flutter paint-like app
// Supports: freehand pen, circle tool, 8 colors, brush size slider, clear

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:test_notifi/features/home-screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Paint',
      theme: ThemeData.light(),
      home: HomeScreen(),
    );
  }
}



