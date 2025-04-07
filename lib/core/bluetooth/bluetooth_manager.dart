import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart'; // kDebugMode를 사용하기 위해 추가

class BluetoothManager {
  Future<List<BluetoothDevice>> scanDevices() async {
    List<BluetoothDevice> devices = [];

    try {
      if (await FlutterBluePlus.isOn == false) {
        // Bluetooth가 꺼져있는 경우
        print("Bluetooth is off!");
        // 사용자에게 Bluetooth를 켜도록 안내하는 코드를 추가하세요.
        return devices; // 빈 목록 반환 또는 오류 처리
      }

      FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      await for (List<ScanResult> results in FlutterBluePlus.scanResults) {
        devices = results.map((result) => result.device).toList();
        break; // 첫 번째 결과만 사용
      }
    } catch (e) {
      // 오류 처리
      print("Error during Bluetooth scan: $e");
      if (kDebugMode) {
        // 디버그 모드에서만 에러 출력
        print(e);
      }
      // 사용자에게 오류 메시지를 표시하거나, 적절한 오류 처리를 수행하세요.
    }

    return devices;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
  }

  Future<void> sendData(BluetoothDevice device, String message) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          await characteristic.write(message.codeUnits);
          break;
        }
      }
    }
  }
}
