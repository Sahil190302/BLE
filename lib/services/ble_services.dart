import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;
  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    await FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(
      license: License.nonprofit, // or License.commercial
      timeout: const Duration(seconds: 15),
    );
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  Stream<BluetoothConnectionState> connectionState(BluetoothDevice device) {
    return device.connectionState;
  }

  Future<List<BluetoothService>> discoverServices(
    BluetoothDevice device,
  ) async {
    return device.discoverServices();
  }

  Future<int?> readBatteryLevel(List<BluetoothService> services) async {
    try {
      final batteryService = services.firstWhere(
        (s) => s.uuid.toString().toLowerCase().contains("180f"),
      );
      final batteryChar = batteryService.characteristics.firstWhere(
        (c) => c.uuid.toString().toLowerCase().contains("2a19"),
      );
      final value = await batteryChar.read();
      if (value.isNotEmpty) return value[0];
    } catch (_) {
      return null;
    }
    return null;
  }
}
