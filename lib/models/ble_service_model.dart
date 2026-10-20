import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleServiceModel {
  final BluetoothService service;
  final List<BleCharacteristicModel> characteristics;

  BleServiceModel({
    required this.service,
    required this.characteristics,
  });

  String get uuid => service.uuid.toString();
}

class BleCharacteristicModel {
  final BluetoothCharacteristic characteristic;
  final String? readValue;
  final bool isReading;

  BleCharacteristicModel({
    required this.characteristic,
    this.readValue,
    this.isReading = false,
  });

  String get uuid => characteristic.uuid.toString();
  bool get canRead => characteristic.properties.read;
  bool get canNotify =>
      characteristic.properties.notify || characteristic.properties.indicate;
}