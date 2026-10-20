import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PermissionHelper {
  static Future<bool> ensureBluetoothReady() async {
    if (await FlutterBluePlus.isSupported == false) {
      return false;
    }

    // Wait for adapter to be on (iOS sometimes reports unknown initially)
    var state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.unknown) {
      await Future.delayed(const Duration(seconds: 1));
      state = await FlutterBluePlus.adapterState.first;
    }

    return state == BluetoothAdapterState.on;
  }

  static Future<void> turnOnBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (_) {
      // User may cancel — that's okay
    }
  }
}