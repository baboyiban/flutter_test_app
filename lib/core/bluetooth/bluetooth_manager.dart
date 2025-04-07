import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager {
  Future<List<BluetoothDevice>> scanDevices() async {
    List<BluetoothDevice> devices = [];
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    await for (List<ScanResult> results in FlutterBluePlus.scanResults) {
      devices = results.map((result) => result.device).toList();
      break; // 첫 번째 결과만 사용
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
