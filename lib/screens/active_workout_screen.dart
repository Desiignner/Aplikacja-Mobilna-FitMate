import 'dart:async';
import 'package:fitmate/models/exercise.dart';
import 'package:fitmate/models/set_details.dart';
import 'package:fitmate/models/scheduled_workout.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final ScheduledWorkout workout;

  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  late Map<SetDetails, bool> _completedSets;

  @override
  void initState() {
    super.initState();
    _completedSets = {
      for (var exercise in widget.workout.exercises)
        for (var set in exercise.sets) set: false
    };
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime = Duration(seconds: _elapsedTime.inSeconds + 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
  
  void _toggleSetCompletion(SetDetails set) {
    setState(() => _completedSets[set] = !_completedSets[set]!);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBackgroundColor,
      appBar: AppBar(title: Text(widget.workout.planName), backgroundColor: cardBackgroundColor, elevation: 0),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: cardBackgroundColor,
            width: double.infinity,
            child: Center(
              child: Column(
                children: [
                  const Text("WORKOUT DURATION", style: TextStyle(color: secondaryTextColor, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text(_formatDuration(_elapsedTime), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
          Expanded(
            child: widget.workout.exercises.isEmpty
                ? const Center(child: Text('No exercises in this plan.', style: TextStyle(color: secondaryTextColor, fontSize: 18)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.workout.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = widget.workout.exercises[index];
                      return _ExerciseInProgressCard(exercise: exercise, completedSets: _completedSets, onToggleSet: _toggleSetCompletion);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Finish Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseInProgressCard extends StatelessWidget {
  final Exercise exercise;
  final Map<SetDetails, bool> completedSets;
  final Function(SetDetails) onToggleSet;

  const _ExerciseInProgressCard({required this.exercise, required this.completedSets, required this.onToggleSet});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2, child: Text('Set', style: TextStyle(color: secondaryTextColor))),
                Expanded(flex: 3, child: Text('Reps', style: TextStyle(color: secondaryTextColor))),
                Expanded(flex: 3, child: Text('Weight (kg)', style: TextStyle(color: secondaryTextColor))),
                SizedBox(width: 48),
              ],
            ),
            const Divider(color: secondaryTextColor),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercise.sets.length,
              itemBuilder: (context, index) {
                final set = exercise.sets[index];
                final isCompleted = completedSets[set] ?? false;
                return _SetRow(set: set, setNumber: index + 1, isCompleted: isCompleted, onToggle: () => onToggleSet(set));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final SetDetails set;
  final int setNumber;
  final bool isCompleted;
  final VoidCallback onToggle;

  const _SetRow({required this.set, required this.setNumber, required this.isCompleted, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: isCompleted ? secondaryTextColor : Colors.white, fontSize: 16, decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text('Set $setNumber', style: textStyle)),
          Expanded(flex: 3, child: Text(set.reps.toString(), style: textStyle)),
          Expanded(flex: 3, child: Text(set.weight.toString(), style: textStyle)),
          IconButton(onPressed: onToggle, icon: Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: isCompleted ? primaryColor : secondaryTextColor)),
        ],
      ),
    );
  }
}