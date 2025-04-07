import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class BluetoothManager {
  Stream<List<ScanResult>> scanDevices({Duration? timeout}) {
    return FlutterBluePlus.scanResults;
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (await FlutterBluePlus.isAvailable == false) {
      throw Exception("Bluetooth not supported");
    }
    await FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
  }

  Future<void> sendData(
    BluetoothDevice device,
    String serviceUUID,
    String characteristicUUID,
    String message,
  ) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUUID) {
            await characteristic.write(utf8.encode(message));
            return;
          }
        }
      }
    }
    throw Exception("Characteristic not found");
  }
}
