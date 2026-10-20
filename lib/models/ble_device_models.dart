import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleDeviceModel {
  final BluetoothDevice device;
  final String name;
  final int rssi;
  final bool isConnectable;

  BleDeviceModel({
    required this.device,
    required this.name,
    required this.rssi,
    required this.isConnectable,
  });

  factory BleDeviceModel.fromScanResult(ScanResult result) {
    return BleDeviceModel(
      device: result.device,
      name: result.device.platformName.isNotEmpty
          ? result.device.platformName
          : "Unknown Device",
      rssi: result.rssi,
      isConnectable: result.advertisementData.connectable,
    );
  }

  String get signalLabel {
    if (rssi >= -50) return "Excellent";
    if (rssi >= -65) return "Good";
    if (rssi >= -80) return "Fair";
    return "Weak";
  }
}