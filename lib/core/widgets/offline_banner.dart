import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: colors.error,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 16, color: colors.onError),
          const SizedBox(width: 8),
          Text(
            'Hors ligne — les données seront synchronisées automatiquement',
            style: TextStyle(color: colors.onError, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
