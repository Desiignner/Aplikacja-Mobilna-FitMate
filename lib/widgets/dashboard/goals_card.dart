import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:flutter/material.dart';

class GoalsCard extends StatelessWidget {
  const GoalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Goals', style: TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.nightlight_round, color: Colors.cyanAccent, size: 30),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sleep', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text('7', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Text('hr', style: TextStyle(color: secondaryTextColor, fontSize: 16)),
                      SizedBox(width: 8),
                      Text('30', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Text('min', style: TextStyle(color: secondaryTextColor, fontSize: 16)),
                    ],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}