import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:flutter/material.dart';

class LastWorkoutCard extends StatelessWidget {
  const LastWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Last Workouts', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.person, color: Colors.grey.shade400, size: 24),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jakub Laba', style: TextStyle(color: Colors.white)),
                  Text('Friday', style: TextStyle(color: secondaryTextColor, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Week3 Upper2', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Bench Press, Omni Grip...', style: TextStyle(color: secondaryTextColor), maxLines: 2, overflow: TextOverflow.ellipsis,),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(4)),
            child: const Text('PR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}