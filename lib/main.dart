import 'package:flutter/material.dart';
import 'dummy.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lapit',
      theme: ThemeData(
        primarySwatch: Colors.purple
      ),
      home: Dummy(),
    );
  }
}