import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/bluetooth/bluetooth_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HC-06 컨트롤러',
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
  final TextEditingController _searchController = TextEditingController(
    text: "HC-06",
  );
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    _devices = [];

    await _btManager.startScan(deviceName: _searchController.text.trim());
    _btManager.scanDevices(deviceName: _searchController.text.trim()).listen((
      devices,
    ) {
      setState(() => _devices = devices);
    });
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() => _isScanning = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HC-06 검색기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 검색 필터 입력창
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '기기 이름 필터',
                hintText: 'HC-06',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _isScanning ? _stopScan : _startScan,
                ),
              ),
            ),
            SizedBox(height: 20),

            // 검색 버튼
            ElevatedButton(
              onPressed: _isScanning ? _stopScan : _startScan,
              child:
                  _isScanning
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 8),
                          Text('검색 중...'),
                        ],
                      )
                      : Text('기기 검색 시작'),
            ),
            SizedBox(height: 20),

            // 검색된 기기 목록
            Expanded(
              child:
                  _devices.isEmpty
                      ? Center(
                        child: Text(_isScanning ? '검색 중...' : '기기를 찾지 못했습니다'),
                      )
                      : ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          return Card(
                            child: ListTile(
                              leading: Icon(Icons.bluetooth),
                              title: Text(
                                device.name.isNotEmpty
                                    ? device.name
                                    : 'Unknown Device',
                              ), // 이름 없을 경우 대체 텍스트
                              subtitle: Text(device.id.toString()),
                              trailing:
                                  _connectedDevice?.id == device.id
                                      ? Icon(Icons.check, color: Colors.green)
                                      : null,
                              onTap: () => _connectDevice(device),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isScanning) {
      FlutterBluePlus.stopScan(); // 또는 _btManager.stopScan() (위에서 메서드 추가 후)
    }
    _searchController.dispose();
    super.dispose();
  }
}
