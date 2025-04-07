import 'package:flutter/material.dart';
import '../core/bluetooth/bluetooth_controller.dart';
import '../core/bluetooth/bluetooth_device_model.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BluetoothController _controller = BluetoothController();
  List<BluetoothDeviceInfo> _devices = [];
  bool _isScanning = false;
  String _receivedData = "";

  @override
  void initState() {
    super.initState();
    _setupBluetooth();
    _controller.dataStream.listen((data) {
      setState(() => _receivedData = data);
    });
  }

  Future<void> _setupBluetooth() async {
    bool? isEnabled = await _controller.bluetooth.isEnabled;
    if (isEnabled != true) {
      await _controller.bluetooth.requestEnable();
    }
  }

  Future<void> _refreshDevices() async {
    setState(() => _isScanning = true);
    _devices = await _controller.scanDevices();
    setState(() => _isScanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('블루투스 관리')),
      body: Column(
        children: [
          _buildControlPanel(),
          Expanded(child: _buildDeviceList()),
          _buildDataMonitor(),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: _isScanning ? null : _refreshDevices,
            child: _isScanning ? CircularProgressIndicator() : Text('기기 새로고침'),
          ),
          if (_controller.isConnected)
            ElevatedButton(
              onPressed: () async {
                await _controller.disconnect();
                setState(() {});
              },
              child: Text('연결 끊기'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    if (_devices.isEmpty) {
      return Center(child: Text(_isScanning ? '검색 중...' : '기기가 없습니다'));
    }
    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (ctx, index) => _buildDeviceItem(_devices[index]),
    );
  }

  Widget _buildDeviceItem(BluetoothDeviceInfo device) {
    return ListTile(
      leading: Icon(Icons.bluetooth),
      title: Text(device.name),
      subtitle: Text(device.address),
      trailing:
          _controller.connectedDeviceAddress == device.address
              ? Icon(Icons.link, color: Colors.green)
              : null,
      onTap: () async {
        await _controller.connectDevice(device.address);
        setState(() {});
      },
    );
  }

  Widget _buildDataMonitor() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            onSubmitted: _controller.sendData,
            decoration: InputDecoration(
              labelText: '메시지 전송',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          Text('수신 데이터: $_receivedData'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.disconnect();
    super.dispose();
  }
}
