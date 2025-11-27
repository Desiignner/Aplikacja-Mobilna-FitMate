import 'package:fitmate/models/exercise.dart';
import 'package:fitmate/models/plan.dart';
import 'package:fitmate/models/scheduled_workout.dart';
import 'package:fitmate/models/set_details.dart';
import 'package:flutter/material.dart';

class AppDataService {
  AppDataService._internal();
  static final AppDataService _instance = AppDataService._internal();
  factory AppDataService() => _instance;

  List<Plan> plans = _getInitialPlans();
  List<ScheduledWorkout> scheduledWorkouts = [];
  final ValueNotifier<Map<String, double>> statistics = ValueNotifier({'totalVolume': 0.0});
  final ValueNotifier<ScheduledWorkout?> lastCompletedWorkout = ValueNotifier(null);

  void addPlan(Plan plan) {
    plans.add(plan);
  }

  void deletePlan(Plan plan) {
    plans.removeWhere((p) => p.id == plan.id);
    scheduledWorkouts.removeWhere((sw) => sw.planId == plan.id);
  }

  void updatePlan(Plan updatedPlan) {
    final index = plans.indexWhere((p) => p.id == updatedPlan.id);
    if (index != -1) {
      plans[index] = updatedPlan;
      for (var workout in scheduledWorkouts) {
        if (workout.planId == updatedPlan.id) {
          workout.planName = updatedPlan.name;
          workout.exercises = updatedPlan.exercises;
        }
      }
    }
  }

  ScheduledWorkout scheduleWorkout(Plan plan, DateTime date) {
    final newScheduledWorkout = ScheduledWorkout(
      id: DateTime.now().millisecondsSinceEpoch,
      date: date,
      planId: plan.id,
      planName: plan.name,
      exercises: plan.exercises,
    );
    scheduledWorkouts.add(newScheduledWorkout);
    return newScheduledWorkout;
  }

  void completeWorkout(ScheduledWorkout workout, BuildContext context) {
    workout.status = WorkoutStatus.completed;
    workout.time = TimeOfDay.now().format(context);
    lastCompletedWorkout.value = workout;

    double volumeFromThisWorkout = 0;
    for (var exercise in workout.exercises) {
      for (var set in exercise.sets) {
        volumeFromThisWorkout += set.reps * set.weight;
      }
    }
    final currentStats = Map<String, double>.from(statistics.value);
    currentStats['totalVolume'] = (currentStats['totalVolume'] ?? 0) + volumeFromThisWorkout;
    statistics.value = currentStats;
  }

  void markAsCompleted(ScheduledWorkout workout, BuildContext context) {
    completeWorkout(workout, context);
  }

  void deleteScheduledWorkout(ScheduledWorkout workout) {
    scheduledWorkouts.removeWhere((sw) => sw.id == workout.id);
    if (workout.status == WorkoutStatus.completed) {
      double volumeFromThisWorkout = 0;
      for (var exercise in workout.exercises) {
        for (var set in exercise.sets) {
          volumeFromThisWorkout += set.reps * set.weight;
        }
      }
      final currentStats = Map<String, double>.from(statistics.value);
      currentStats['totalVolume'] = (currentStats['totalVolume'] ?? 0) - volumeFromThisWorkout;
      statistics.value = currentStats;
    }
  }

  List<ScheduledWorkout> getWorkoutsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return scheduledWorkouts.where((workout) {
      final workoutDay = DateTime.utc(workout.date.year, workout.date.month, workout.date.day);
      return workoutDay == normalizedDay;
    }).toList();
  }
}

List<Plan> _getInitialPlans() {
  return [
    Plan(id: 1, name: 'Full Body A', exercises: [
      Exercise(name: 'Bench Press', rest: 90, sets: [
        SetDetails(reps: 8, weight: 60.0),
        SetDetails(reps: 8, weight: 60.0),
      ]),
    ]),
    Plan(id: 2, name: 'Full Body B', exercises: [
      Exercise(name: 'Squat', rest: 120, sets: [SetDetails(reps: 10, weight: 80.0)]),
    ]),
  ];
}