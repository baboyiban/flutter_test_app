class BluetoothDeviceInfo {
  final String name;
  final String address;
  final bool isConnected;

  BluetoothDeviceInfo({
    required this.name,
    required this.address,
    this.isConnected = false,
  });
}
