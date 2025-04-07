import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'bluetooth_device_model.dart';

class BluetoothController {
  final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  String? _connectedAddress;

  // 기기 검색
  Future<List<BluetoothDeviceInfo>> scanDevices() async {
    List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
    return bondedDevices
        .where((device) => device.name?.isNotEmpty ?? false)
        .map(
          (device) => BluetoothDeviceInfo(
            name: device.name ?? "Unknown",
            address: device.address,
          ),
        )
        .toList();
  }

  // 기기 연결
  Future<void> connectDevice(String address) async {
    connection = await BluetoothConnection.toAddress(address);
    _connectedAddress = address; // Store connected address
  }

  // 데이터 전송
  Future<void> sendData(String message) async {
    if (connection?.isConnected ?? false) {
      connection!.output.add(Uint8List.fromList(utf8.encode("$message\r\n")));
      await connection!.output.allSent;
    }
  }

  // 연결 종료
  Future<void> disconnect() async {
    await connection?.close();
    connection = null;
    _connectedAddress = null; // Clear connected address
  }

  // 현재 연결 상태
  String? get connectedDeviceAddress => _connectedAddress;
  bool get isConnected => connection?.isConnected ?? false;

  // 데이터 스트림
  Stream<String> get dataStream async* {
    if (connection != null) {
      await for (Uint8List data in connection!.input!) {
        yield String.fromCharCodes(data);
      }
    }
  }
}
