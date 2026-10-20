import 'package:flutter/material.dart';

enum StatusBannerType { info, warning, error }

class StatusBanner extends StatelessWidget {
  final StatusBannerType type;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const StatusBanner({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (type) {
      StatusBannerType.info => (
          Colors.blue.withOpacity(0.08),
          Colors.blue.shade700,
          Icons.info_outline,
        ),
      StatusBannerType.warning => (
          Colors.orange.withOpacity(0.10),
          Colors.orange.shade800,
          Icons.warning_amber_rounded,
        ),
      StatusBannerType.error => (
          Colors.red.withOpacity(0.08),
          Colors.red.shade700,
          Icons.error_outline,
        ),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: fg,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: fg.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: fg,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}