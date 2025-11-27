import 'package:fitmate/models/plan.dart';
import 'package:fitmate/models/scheduled_workout.dart';
import 'package:fitmate/screens/active_workout_screen.dart';
import 'package:fitmate/screens/create_plan_screen.dart';
import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:flutter/material.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final AppDataService _appData = AppDataService();

  void _navigateAndAddPlan() async {
    final newPlan = await Navigator.of(context).push<Plan>(
      MaterialPageRoute(builder: (context) => const CreatePlanScreen()),
    );
    if (newPlan != null) {
      setState(() {
        _appData.addPlan(newPlan);
      });
    }
  }

  void _startWorkout(Plan plan) async {
    final newWorkout = _appData.scheduleWorkout(plan, DateTime.now());
    
    final bool? workoutFinished = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => ActiveWorkoutScreen(workout: newWorkout)),
    );

    if (workoutFinished == true && mounted) {
      setState(() {
        _appData.completeWorkout(newWorkout, context);
      });
    }
  }

  void _deletePlan(Plan plan) {
    setState(() {
      _appData.deletePlan(plan);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'${plan.name}' deleted."),
        action: SnackBarAction(label: 'UNDO', onPressed: () {
          setState(() {
            _appData.addPlan(plan);
          });
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final allPlans = _appData.plans;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plans'),
        actions: [
          IconButton(onPressed: _navigateAndAddPlan, icon: const Icon(Icons.add, color: primaryColor, size: 30)),
        ],
      ),
      body: allPlans.isEmpty
          ? const Center(child: Text('No workout plans yet.\nPress "+" to add one!', textAlign: TextAlign.center, style: TextStyle(color: secondaryTextColor, fontSize: 18)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allPlans.length,
              itemBuilder: (context, index) {
                final plan = allPlans[index];
                return Dismissible(
                  key: ValueKey(plan.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _deletePlan(plan),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: _WorkoutPlanCard(plan: plan, onStart: () => _startWorkout(plan)),
                );
              },
            ),
    );
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onStart;

  const _WorkoutPlanCard({required this.plan, required this.onStart});

  @override
  Widget build(BuildContext context) {
  
    final description = plan.description.isNotEmpty ? plan.description : "${plan.exercises.length} exercises";
    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(color: secondaryTextColor, fontSize: 16)),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: mainBackgroundColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                child: const Text('Start Workout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}