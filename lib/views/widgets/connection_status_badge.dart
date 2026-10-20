import 'package:assignment/controllers/ble_controllers.dart';
import 'package:flutter/material.dart';

class ConnectionStatusBadge extends StatelessWidget {
  final BleConnectionStatus status;
  const ConnectionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      BleConnectionStatus.connected => (
          "Connected",
          Colors.green,
          Icons.bluetooth_connected
        ),
      BleConnectionStatus.connecting => (
          "Connecting…",
          Colors.orange,
          Icons.bluetooth_searching
        ),
      BleConnectionStatus.disconnecting => (
          "Disconnecting…",
          Colors.orange,
          Icons.bluetooth_disabled
        ),
      BleConnectionStatus.disconnected => (
          "Disconnected",
          Colors.red,
          Icons.bluetooth_disabled
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}