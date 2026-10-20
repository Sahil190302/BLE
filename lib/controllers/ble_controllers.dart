
import 'dart:async';

import 'package:assignment/models/ble_device_models.dart';
import 'package:assignment/services/ble_services.dart';
import 'package:assignment/utils/error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../models/ble_service_model.dart';

enum BleConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

class BleController extends ChangeNotifier {
  final BleService _bleService;

  BleController({BleService? bleService})
      : _bleService = bleService ?? BleService() {
    _initAdapterListener();
  }

  // State
  List<BleDeviceModel> _devices = [];
  BluetoothDevice? _connectedDevice;
  BleConnectionStatus _connectionStatus =
      BleConnectionStatus.disconnected;
  List<BleServiceModel> _services = [];
  int? _batteryLevel;
  String? _errorMessage;

  bool _isDiscoveringServices = false;
  bool _isScanning = false;
  bool _permissionDenied = false;

  BluetoothAdapterState _adapterState =
      BluetoothAdapterState.unknown;

  // Stream subscriptions
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<BluetoothAdapterState>? _adapterLogSub;

  bool _disposed = false;

  // Getters
  List<BleDeviceModel> get devices => _devices;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  BleConnectionStatus get connectionStatus => _connectionStatus;
  List<BleServiceModel> get services => _services;
  int? get batteryLevel => _batteryLevel;
  String? get errorMessage => _errorMessage;

  bool get isDiscoveringServices => _isDiscoveringServices;
  bool get isScanning => _isScanning;
  bool get permissionDenied => _permissionDenied;
  BluetoothAdapterState get adapterState => _adapterState;

  bool get isBluetoothOn =>
      _adapterState == BluetoothAdapterState.on;

  bool get isConnected =>
      _connectionStatus == BleConnectionStatus.connected;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Adapter listener
  void _initAdapterListener() {
    _adapterSub?.cancel();

    _adapterSub = _bleService.adapterState.listen(
      (state) {
        _adapterState = state;
        _notify();
      },
      onError: (Object error) {
        DebugLog.e('Bluetooth', 'Adapter state error: $error');
      },
    );
  }

  // Start BLE scan
  Future<void> startScan() async {
    DebugLog.d('Scan', 'startScan() called');

    if (_isScanning) {
      DebugLog.d('Scan', 'Scan already running');
      return;
    }

    _errorMessage = null;
    _permissionDenied = false;
    _devices = [];
    _notify();

    try {
      // 1. Check Bluetooth state
      _adapterState = await _bleService.adapterState.first;

      DebugLog.d('Scan', 'Adapter state: $_adapterState');

      if (!isBluetoothOn) {
        _errorMessage =
            'Bluetooth is off. Please turn it on to scan.';
        _notify();
        return;
      }

      // 2. Request permissions
      DebugLog.d('Scan', 'Requesting Bluetooth permissions');

      final statuses = await <ph.Permission>[
        ph.Permission.bluetoothScan,
        ph.Permission.bluetoothConnect,
      ].request();

      for (final entry in statuses.entries) {
        DebugLog.d(
          'Scan',
          '${entry.key}: ${entry.value}',
        );
      }

      if (statuses.values.any((status) => !status.isGranted)) {
        _permissionDenied = true;
        _errorMessage =
            'Bluetooth permissions denied. Enable them in Settings.';
        _notify();
        return;
      }

      DebugLog.d('Scan', 'Permissions granted');

      // 3. Subscribe to scan results BEFORE starting the scan.
      await _scanSub?.cancel();

      _scanSub = _bleService.scanResults.listen(
        (results) {
          DebugLog.d(
            'Scan',
            'Received ${results.length} scan result(s)',
          );

          for (final result in results) {
            DebugLog.d(
              'Scan',
              '${result.device.platformName.isEmpty ? "(no name)" : result.device.platformName} '
              '| ID=${result.device.remoteId} '
              '| RSSI=${result.rssi} '
              '| connectable=${result.advertisementData.connectable}',
            );
          }

          // Display ALL discovered devices.
          // Do not remove non-connectable advertisers here.
          final discovered = results
              .map((result) => BleDeviceModel.fromScanResult(result))
              .toList()
            ..sort((a, b) => b.rssi.compareTo(a.rssi));

          _devices = discovered;
          _notify();
        },
        onError: (Object error) {
          DebugLog.e('Scan', 'Scan results error: $error');
          _errorMessage = 'Unable to read scan results: $error';
          _notify();
        },
        onDone: () {
          DebugLog.d('Scan', 'Scan results stream closed');
        },
      );

      // 4. Listen for scan-state changes.
      await _isScanningSub?.cancel();

      _isScanningSub = _bleService.isScanning.listen(
        (scanning) {
          DebugLog.d('Scan', 'isScanning → $scanning');

          _isScanning = scanning;
          _notify();
        },
        onError: (Object error) {
          DebugLog.e('Scan', 'Scan-state stream error: $error');
        },
      );

      // 5. Start scanning.
      _isScanning = true;
      _notify();

      DebugLog.d('Scan', 'Starting BLE scan');

      await _bleService.startScan();

      DebugLog.d('Scan', 'startScan() returned');
    } catch (error, stackTrace) {
      DebugLog.e('Scan', 'Exception: $error');
      DebugLog.e('Scan', 'Stack trace: $stackTrace');

      _isScanning = false;
      _errorMessage =
          ErrorHandler.prettyException('Scan Error', error);
      _notify();
    }
  }

  // Stop BLE scan
  Future<void> stopScan() async {
    DebugLog.d('Scan', 'stopScan() called');

    try {
      await _bleService.stopScan();
    } catch (error) {
      DebugLog.e('Scan', 'Error stopping scan: $error');
    } finally {
      _isScanning = false;
      await _scanSub?.cancel();
      _scanSub = null;
      _notify();
    }
  }

  // Request Bluetooth to turn on
  Future<void> requestBluetoothOn() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (error) {
      DebugLog.e(
        'Bluetooth',
        'Unable to turn Bluetooth on: $error',
      );
    }
  }

  // Open application settings
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  // Connect to a selected device
  Future<void> connect(BleDeviceModel model) async {
    if (!model.isConnectable) {
      _errorMessage =
          'This BLE device is not advertising as connectable.';
      _notify();
      return;
    }

    await stopScan();

    _connectionStatus = BleConnectionStatus.connecting;
    _errorMessage = null;
    _notify();

    try {
      await _bleService.connect(model.device);

      _connectedDevice = model.device;

      await _connectionSub?.cancel();

      _connectionSub = _bleService
          .connectionState(model.device)
          .listen(
        (state) {
          DebugLog.d('Connection', 'State: $state');

          if (state == BluetoothConnectionState.disconnected) {
            _handleDisconnection();
          } else if (state == BluetoothConnectionState.connected) {
            _connectionStatus = BleConnectionStatus.connected;
            _notify();
            _discoverServices();
          }
        },
        onError: (Object error) {
          DebugLog.e('Connection', 'State error: $error');
          _errorMessage = ErrorHandler.prettyException(
            'Connection Error',
            error,
          );
          _handleDisconnection();
        },
      );
    } catch (error) {
      _connectionStatus = BleConnectionStatus.disconnected;
      _errorMessage =
          ErrorHandler.prettyException('Connection Error', error);
      _notify();
    }
  }

  // Discover services and characteristics
  Future<void> _discoverServices() async {
    final device = _connectedDevice;
    if (device == null) return;

    _isDiscoveringServices = true;
    _notify();

    try {
      final rawServices = await _bleService.discoverServices(device);

      _services = rawServices.map((service) {
        return BleServiceModel(
          service: service,
          characteristics: service.characteristics.map((characteristic) {
            return BleCharacteristicModel(
              characteristic: characteristic,
            );
          }).toList(),
        );
      }).toList();

      _batteryLevel =
          await _bleService.readBatteryLevel(rawServices);
    } catch (error) {
      _errorMessage = ErrorHandler.prettyException(
        'Service Discovery',
        error,
      );
    } finally {
      _isDiscoveringServices = false;
      _notify();
    }
  }

  // Read a characteristic
  Future<void> readCharacteristic(
    BleCharacteristicModel model,
  ) async {
    if (!model.canRead) return;

    try {
      final value = await model.characteristic.read();

      for (final service in _services) {
        final index = service.characteristics.indexOf(model);

        if (index != -1) {
          service.characteristics[index] = BleCharacteristicModel(
            characteristic: model.characteristic,
            readValue: value
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join(' '),
          );

          _notify();
          return;
        }
      }
    } catch (error) {
      _errorMessage =
          ErrorHandler.prettyException('Read Error', error);
      _notify();
    }
  }

  // Reconnect to the current device
  Future<void> reconnect() async {
    final device = _connectedDevice;
    if (device == null) return;

    await connect(
      BleDeviceModel(
        device: device,
        name: device.platformName,
        rssi: -100,
        isConnectable: true,
      ),
    );
  }

  // Disconnect from the current device
  Future<void> disconnect() async {
    final device = _connectedDevice;
    if (device == null) return;

    _connectionStatus = BleConnectionStatus.disconnecting;
    _notify();

    try {
      await _bleService.disconnect(device);
    } catch (error) {
      DebugLog.e('Connection', 'Disconnect error: $error');
    }

    _handleDisconnection();
  }

  void _handleDisconnection() {
    _connectionStatus = BleConnectionStatus.disconnected;
    _connectedDevice = null;
    _services = [];
    _batteryLevel = null;
    _isDiscoveringServices = false;

    _connectionSub?.cancel();
    _connectionSub = null;

    _notify();
  }

  // Clear errors
  void clearError() {
    _errorMessage = null;
    _permissionDenied = false;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;

    _scanSub?.cancel();
    _connectionSub?.cancel();
    _adapterSub?.cancel();
    _isScanningSub?.cancel();
    _adapterLogSub?.cancel();

    super.dispose();
  }
}
