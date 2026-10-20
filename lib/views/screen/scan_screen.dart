import 'package:assignment/controllers/ble_controllers.dart';
import 'package:assignment/views/screen/device_detail_screen.dart';
import 'package:assignment/views/widgets/device_tile.dart';
import 'package:assignment/views/widgets/status_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Devices"),
        actions: [
          Consumer<BleController>(
            builder: (_, controller, __) {
              if (!controller.isConnected) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeviceDetailScreen(),
                  ),
                ),
                icon: const Icon(Icons.bluetooth_connected),
                label: const Text("Connected"),
              );
            },
          ),
        ],
      ),
      body: Consumer<BleController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              // ── Top banners ──────────────────────────────
              if (!controller.isBluetoothOn)
                StatusBanner(
                  type: StatusBannerType.warning,
                  title: "Bluetooth is off",
                  message:
                      "Turn on Bluetooth to discover nearby BLE devices.",
                  actionLabel: "Turn on",
                  onAction: controller.requestBluetoothOn,
                ),
              if (controller.permissionDenied)
                StatusBanner(
                  type: StatusBannerType.error,
                  title: "Permission required",
                  message:
                      "Bluetooth permissions are denied. Enable them from app settings.",
                  actionLabel: "Open Settings",
                  onAction: controller.openAppSettings,
                ),
              if (controller.errorMessage != null &&
                  !controller.permissionDenied)
                StatusBanner(
                  type: StatusBannerType.error,
                  title: "Something went wrong",
                  message: controller.errorMessage!,
                  actionLabel: "Retry",
                  onAction: () {
                    controller.clearError();
                    controller.startScan();
                  },
                ),

              // ── Scanning indicator ───────────────────────
              if (controller.isScanning)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text("Scanning for nearby devices…"),
                    ],
                  ),
                ),

              // ── Main content ─────────────────────────────
              Expanded(
                child: _buildContent(context, controller),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<BleController>(
        builder: (_, controller, __) {
          final theme = Theme.of(context);
          final isConnecting = controller.connectionStatus ==
              BleConnectionStatus.connecting;

          // ── Connecting state: neutral disabled pill ──
          if (isConnecting) {
            return FloatingActionButton.extended(
              onPressed: null,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              icon: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              label: const Text("Connecting…"),
            );
          }

          final canScan = controller.isBluetoothOn;
          final isConnected = controller.isConnected;

          // ── Disabled: Bluetooth off ──
          if (!canScan && !isConnected) {
            return FloatingActionButton.extended(
              onPressed: null,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text("Scan"),
            );
          }

          // ── Active: bright, auto-contrast ──
          return FloatingActionButton.extended(
            onPressed: () {
              if (isConnected) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeviceDetailScreen(),
                  ),
                );
              } else {
                controller.startScan();
              }
            },
            // Bright, professional primary color from theme
            backgroundColor: theme.colorScheme.primary,
            // Flutter auto-picks contrasting text/icon color
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 6,
            icon: Icon(
              isConnected ? Icons.bluetooth_connected : Icons.search,
            ),
            label: Text(
              isConnected ? "View Device" : "Scan",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BleController controller) {
    if (controller.devices.isEmpty) {
      return _EmptyState(
        isScanning: controller.isScanning,
        bluetoothOn: controller.isBluetoothOn,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      itemCount: controller.devices.length,
      itemBuilder: (context, index) {
        final device = controller.devices[index];
        return DeviceTile(
          device: device,
          onTap: () async {
            await controller.connect(device);
            if (!context.mounted) return;
            if (controller.isConnected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeviceDetailScreen(),
                ),
              );
            } else if (controller.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(controller.errorMessage!)),
              );
            }
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isScanning;
  final bool bluetoothOn;

  const _EmptyState({required this.isScanning, required this.bluetoothOn});

  @override
  Widget build(BuildContext context) {
    if (isScanning) {
      return const SizedBox.shrink();
    }

    final (icon, title, subtitle) = bluetoothOn
        ? (
            Icons.bluetooth_searching,
            "No devices found",
            "Tap Scan to search for nearby BLE devices."
          )
        : (
            Icons.bluetooth_disabled,
            "Bluetooth is off",
            "Turn on Bluetooth to start discovering devices."
          );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}