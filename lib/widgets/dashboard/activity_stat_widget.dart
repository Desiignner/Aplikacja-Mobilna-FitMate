import 'package:fitmate/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ActivityStat extends StatelessWidget {
  final String label;
  final String value;
  const ActivityStat({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: secondaryTextColor, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}