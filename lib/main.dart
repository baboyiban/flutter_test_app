import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arduino Bluetooth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> _devices = [];
  bool _isConnected = false;
  TextEditingController _messageController = TextEditingController();
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.location.request();
  }

  Future<void> _scanDevices() async {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _devices = results.map((result) => result.device).toList();
      });
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
    setState(() {
      _connectedDevice = device;
      _isConnected = true;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty && _connectedDevice != null) {
      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            await characteristic.write(_messageController.text.codeUnits);
            break;
          }
        }
      }
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HC-06 연결 앱')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _scanDevices,
              child: Text('기기 검색'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_devices[index].platformName),
                    subtitle: Text(_devices[index].remoteId.toString()),
                    onTap: () => _connectToDevice(_devices[index]),
                  );
                },
              ),
            ),
            if (_isConnected) ...[
              TextField(
                controller: _messageController,
                decoration: InputDecoration(labelText: '메시지 입력'),
              ),
              ElevatedButton(
                onPressed: _sendMessage,
                child: Text('전송'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
