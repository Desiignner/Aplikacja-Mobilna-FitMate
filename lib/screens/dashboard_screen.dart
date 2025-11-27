import 'package:fitmate/models/scheduled_workout.dart';
import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:fitmate/widgets/dashboard/activity_calendar_widget.dart';
import 'package:fitmate/widgets/dashboard/goals_card.dart';
import 'package:fitmate/widgets/dashboard/physical_activity_card.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              const PhysicalActivityCard(),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildLastWorkoutCard()),
                  const SizedBox(width: 16),
                  const Expanded(child: ActivityCalendarWidget()),
                ],
              ),
              const SizedBox(height: 24),
              const GoalsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Dashboard', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
          child: const Icon(Icons.person, color: mainBackgroundColor),
        ),
      ],
    );
  }

  Widget _buildLastWorkoutCard() {
    final AppDataService appData = AppDataService();
    return ValueListenableBuilder<ScheduledWorkout?>(
      valueListenable: appData.lastCompletedWorkout,
      builder: (context, lastWorkout, child) {
        if (lastWorkout == null) {
          return const AppCard(child: SizedBox(height: 150, child: Center(child: Text("No workouts completed yet.", style: TextStyle(color: secondaryTextColor)))));
        }
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Last Workout', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              Text(lastWorkout.planName, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Completed at ${lastWorkout.time}', style: const TextStyle(color: secondaryTextColor)),
            ],
          ),
        );
      },
    );
  }
}