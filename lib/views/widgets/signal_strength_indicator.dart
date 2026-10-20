import 'package:flutter/material.dart';

class SignalStrengthIndicator extends StatelessWidget {
  final int rssi;
  const SignalStrengthIndicator({super.key, required this.rssi});

  @override
  Widget build(BuildContext context) {
    final strength = ((rssi + 100) / 60).clamp(0.0, 1.0);
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: strength,
            backgroundColor: Colors.grey.shade300,
            color: strength > 0.6
                ? Colors.green
                : strength > 0.3
                    ? Colors.orange
                    : Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Text("$rssi dBm"),
      ],
    );
  }
}