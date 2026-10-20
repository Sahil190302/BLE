import 'package:flutter/material.dart';
import '../../models/ble_service_model.dart';

class ServiceCharacteristicCard extends StatelessWidget {
  final BleServiceModel service;
  final void Function(BleCharacteristicModel) onReadCharacteristic;

  const ServiceCharacteristicCard({
    super.key,
    required this.service,
    required this.onReadCharacteristic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.settings_bluetooth),
        title: Text(
          _friendlyServiceName(service.uuid),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "UUID: ${service.uuid}",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        children: service.characteristics
            .map((c) => _CharacteristicTile(
                  model: c,
                  onRead: () => onReadCharacteristic(c),
                ))
            .toList(),
      ),
    );
  }

  /// Maps well-known GATT UUIDs to friendly names.
  String _friendlyServiceName(String uuid) {
    final lower = uuid.toLowerCase();
    if (lower.contains("1800")) return "Generic Access";
    if (lower.contains("1801")) return "Generic Attribute";
    if (lower.contains("180a")) return "Device Information";
    if (lower.contains("180f")) return "Battery Service";
    if (lower.contains("180d")) return "Heart Rate";
    if (lower.contains("1809")) return "Health Thermometer";
    if (lower.contains("1812")) return "Human Interface Device";
    return "Custom Service";
  }
}

class _CharacteristicTile extends StatelessWidget {
  final BleCharacteristicModel model;
  final VoidCallback onRead;

  const _CharacteristicTile({required this.model, required this.onRead});

  @override
  Widget build(BuildContext context) {
    final props = <String>[
      if (model.canRead) "Read",
      if (model.characteristic.properties.write) "Write",
      if (model.characteristic.properties.notify) "Notify",
      if (model.characteristic.properties.indicate) "Indicate",
    ];

    return ListTile(
      dense: true,
      leading: const Icon(Icons.memory, size: 20),
      title: Text(
        model.uuid,
        style: const TextStyle(fontSize: 13, fontFamily: "monospace"),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: props
                .map((p) => Chip(
                      label: Text(p, style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
          if (model.readValue != null) ...[
            const SizedBox(height: 6),
            Text(
              "Value: 0x${model.readValue}",
              style: TextStyle(
                fontSize: 12,
                fontFamily: "monospace",
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
      trailing: model.canRead
          ? IconButton(
              tooltip: "Read value",
              icon: const Icon(Icons.download),
              onPressed: onRead,
            )
          : null,
    );
  }
}