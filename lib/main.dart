import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'core/bluetooth/bluetooth_manager.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE HC-06 컨트롤러',
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
  final BluetoothManager _btManager = BluetoothManager();
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupBluetoothListener();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Android 12+에서는 BLUETOOTH_CONNECT 권한이 필요
    if (Platform.isAndroid) {
      await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.locationWhenInUse,
      ].request();
    } else if (Platform.isIOS) {
      await Permission.bluetooth.request();
    }
  }

  void _setupBluetoothListener() {
    _btManager.scanDevices().listen((results) {
      setState(() => _scanResults = results);
    });
  }

  Future<void> _toggleScan() async {
    if (_isScanning) {
      await _btManager.stopScan();
    } else {
      await _btManager.startScan();
    }
    setState(() => _isScanning = !_isScanning);
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    try {
      await _btManager.connectToDevice(device);
      setState(() => _connectedDevice = device);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${device.name} 연결 성공')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('연결 실패: $e')));
    }
  }

  Future<void> _sendMessage() async {
    if (_connectedDevice == null || _messageController.text.isEmpty) return;

    try {
      // HC-06 BLE 에뮬레이션 시 UUID (실제 디바이스 값으로 변경 필요)
      const String serviceUUID = "0000ffe0-0000-1000-8000-00805f9b34fb";
      const String charUUID = "0000ffe1-0000-1000-8000-00805f9b34fb";

      await _btManager.sendData(
        _connectedDevice!,
        serviceUUID,
        charUUID,
        _messageController.text,
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('전송 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HC-06 BLE 컨트롤러')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _toggleScan,
              child:
                  _isScanning
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 8),
                          Text('스캔 중...'),
                        ],
                      )
                      : Text('기기 검색 시작'),
            ),
            Expanded(
              child:
                  _scanResults.isEmpty
                      ? Center(child: Text('검색된 기기가 없습니다'))
                      : ListView.builder(
                        itemCount: _scanResults.length,
                        itemBuilder: (context, index) {
                          final device = _scanResults[index].device;
                          return ListTile(
                            title: Text(device.name),
                            subtitle: Text(device.id.toString()),
                            trailing:
                                _connectedDevice?.id == device.id
                                    ? Icon(Icons.check, color: Colors.green)
                                    : null,
                            onTap: () => _connectDevice(device),
                          );
                        },
                      ),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'HC-06에 보낼 메시지',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _btManager.stopScan();
    super.dispose();
  }
}
