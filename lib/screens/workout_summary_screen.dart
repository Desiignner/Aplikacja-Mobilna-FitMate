import 'package:fitmate/models/exercise.dart';
import 'package:fitmate/models/plan.dart';
import 'package:fitmate/models/scheduled_workout.dart';
import 'package:fitmate/screens/create_plan_screen.dart'; 
import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final ScheduledWorkout workout;
  const WorkoutSummaryScreen({super.key, required this.workout});

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  final AppDataService _appData = AppDataService();
  late ScheduledWorkout currentWorkout;

  @override
  void initState() {
    super.initState();

    currentWorkout = widget.workout;
  }

  void _navigateToEditScreen() async {

    final planToEdit = _appData.plans.firstWhere(
      (p) => p.id == currentWorkout.planId,
      orElse: () => Plan(id: -1, name: 'Not Found'), 
    );

    if (planToEdit.id == -1) return;


    final updatedPlan = await Navigator.of(context).push<Plan>(
      MaterialPageRoute(builder: (context) => CreatePlanScreen(planToEdit: planToEdit)),
    );

    if (updatedPlan != null && mounted) {

      _appData.updatePlan(updatedPlan);

      setState(() {
        currentWorkout.planName = updatedPlan.name;
        currentWorkout.exercises = updatedPlan.exercises;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentWorkout.planName),
        backgroundColor: cardBackgroundColor,
        actions: [
          // Przycisk "Edytuj"
          IconButton(
            icon: const Icon(Icons.edit, color: primaryColor),
            onPressed: _navigateToEditScreen,
            tooltip: 'Edit Plan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryHeader(),
            const SizedBox(height: 24),
            const Text(
              'Exercises Performed',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentWorkout.exercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final exercise = currentWorkout.exercises[index];
                return _ExerciseSummaryCard(exercise: exercise);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Card(
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: secondaryTextColor, size: 18),
                const SizedBox(width: 8),
                Text(DateFormat.yMMMMd().format(currentWorkout.date), style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time_filled, color: secondaryTextColor, size: 18),
                const SizedBox(width: 8),
                Text('Completed at ${currentWorkout.time}', style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _ExerciseSummaryCard extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseSummaryCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: Text('Set', style: TextStyle(color: secondaryTextColor))),
                Expanded(child: Text('Reps', style: TextStyle(color: secondaryTextColor))),
                Expanded(child: Text('Weight', style: TextStyle(color: secondaryTextColor))),
              ],
            ),
            const Divider(color: secondaryTextColor),
            for (var i = 0; i < exercise.sets.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(child: Text('${i + 1}', style: const TextStyle(color: Colors.white))),
                    Expanded(child: Text(exercise.sets[i].reps.toString(), style: const TextStyle(color: Colors.white))),
                    Expanded(child: Text('${exercise.sets[i].weight} kg', style: const TextStyle(color: Colors.white))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}