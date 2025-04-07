import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class BluetoothManager {
  // 특정 이름으로 기기 검색 (대소문자 무시)
  Stream<List<BluetoothDevice>> scanDevices({String? deviceName}) async* {
    await for (List<ScanResult> results in FlutterBluePlus.scanResults) {
      // 이름이 있는 기기만 필터링
      var filteredDevices =
          results
              .where(
                (result) => result.device.name.isNotEmpty,
              ) // 이름이 비어있지 않은 기기만
              .map((result) => result.device)
              .toList();

      if (deviceName != null) {
        filteredDevices =
            filteredDevices
                .where(
                  (device) => device.name.toLowerCase().contains(
                    deviceName.toLowerCase(),
                  ),
                )
                .toList();
      }

      yield filteredDevices;
    }
  }

  Future<void> startScan({
    String? deviceName,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: false,
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
  }

  Future<void> sendData(BluetoothDevice device, String message) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          await characteristic.write(utf8.encode(message));
          return;
        }
      }
    }
    throw Exception("쓰기 가능한 특성을 찾을 수 없음");
  }
}
