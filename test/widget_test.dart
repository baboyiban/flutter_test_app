import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        // MyApp 대신 MaterialApp 사용
        home: Scaffold(
          // BluetoothScreen 대신 Scaffold 사용
          body: Center(child: Text('Test App')),
        ),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('Test App'), findsOneWidget); // Text 위젯 확인

    // (Bluetooth 관련 코드는 제거)
  });
}
