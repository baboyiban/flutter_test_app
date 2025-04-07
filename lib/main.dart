import 'package:flutter/material.dart';
import 'views/bluetooth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '블루투스 컨트롤러',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BluetoothScreen(),
    );
  }
}
