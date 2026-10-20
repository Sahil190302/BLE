import 'package:assignment/controllers/ble_controllers.dart';
import 'package:assignment/views/widgets/connection_status_badge.dart';
import 'package:assignment/views/widgets/service_characterstics_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BleController>(
      builder: (context, controller, _) {
        final device = controller.connectedDevice;
        final deviceName = (device?.platformName.isNotEmpty ?? false)
            ? device!.platformName
            : "Unknown Device";

        return Scaffold(
          appBar: AppBar(
            title: Text(deviceName),
            actions: [
              if (controller.isConnected)
                IconButton(
                  tooltip: "Disconnect",
                  icon: const Icon(Icons.link_off),
                  onPressed: () async {
                    await controller.disconnect();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
            ],
          ),
          body: _buildBody(context, controller),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BleController controller) {
    // --- Connection lost / not connected ---
    if (!controller.isConnected) {
      final isReconnecting =
          controller.connectionStatus == BleConnectionStatus.connecting;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withOpacity(0.5),
                ),
                child: Icon(
                  Icons.bluetooth_disabled,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isReconnecting ? "Reconnecting…" : "Device Disconnected",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "The connection to the device was lost.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              if (isReconnecting)
                const CircularProgressIndicator()
              else
                FilledButton.icon(
                  onPressed: controller.reconnect,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reconnect"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to scan"),
              ),
            ],
          ),
        ),
      );
    }

    // --- Discovering services ---
    if (controller.isDiscoveringServices) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Discovering services…"),
          ],
        ),
      );
    }

    // --- Error during discovery ---
    if (controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 56, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              Text(controller.errorMessage!,
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  controller.clearError();
                  controller.reconnect();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // --- No services found ---
    if (controller.services.isEmpty) {
      return const Center(child: Text("No services found on this device."));
    }

    // --- Main content ---
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Device hero card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bluetooth_connected,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.connectedDevice?.platformName.isNotEmpty ==
                              true
                          ? controller.connectedDevice!.platformName
                          : "Unknown Device",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    ConnectionStatusBadge(
                        status: controller.connectionStatus),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Battery card
        _BatteryCard(batteryLevel: controller.batteryLevel),
        const SizedBox(height: 24),

        // Services header
        Row(
          children: [
            const Icon(Icons.settings_bluetooth, size: 18),
            const SizedBox(width: 8),
            Text(
              "Services (${controller.services.length})",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...controller.services.map(
          (service) => ServiceCharacteristicCard(
            service: service,
            onReadCharacteristic: controller.readCharacteristic,
          ),
        ),
      ],
    );
  }
}

class _BatteryCard extends StatelessWidget {
  final int? batteryLevel;
  const _BatteryCard({required this.batteryLevel});

  @override
  Widget build(BuildContext context) {
    final hasBattery = batteryLevel != null;
    final pct = batteryLevel ?? 0;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasBattery
                  ? (pct > 20 ? Colors.green : Colors.red).withOpacity(0.15)
                  : Colors.grey.withOpacity(0.15),
            ),
            child: Icon(
              hasBattery
                  ? (pct > 80
                      ? Icons.battery_full
                      : pct > 40
                          ? Icons.battery_5_bar
                          : pct > 15
                              ? Icons.battery_2_bar
                              : Icons.battery_alert)
                  : Icons.battery_unknown,
              color: hasBattery
                  ? (pct > 20 ? Colors.green : Colors.red)
                  : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Battery Level",
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  hasBattery ? "$pct%" : "Not supported",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasBattery
                        ? (pct > 20 ? Colors.green.shade700 : Colors.red)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (hasBattery)
            SizedBox(
              width: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: pct > 20 ? Colors.green : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}