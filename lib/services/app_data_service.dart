import 'dart:convert';
import 'package:fitmate/api/api_client.dart';
import 'package:fitmate/models/plan.dart';
import 'package:fitmate/models/scheduled_workout.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AppDataService {
  AppDataService._internal();
  static final AppDataService _instance = AppDataService._internal();
  factory AppDataService() => _instance;

  final ApiClient apiClient = ApiClient();
  List<Plan> plans = [];
  List<ScheduledWorkout> scheduledWorkouts = [];
  final ValueNotifier<Map<String, double>> statistics =
      ValueNotifier({'totalVolume': 0.0});
  final ValueNotifier<ScheduledWorkout?> lastCompletedWorkout =
      ValueNotifier(null);

  // Metrics
  final ValueNotifier<Map<String, String>> userMetrics = ValueNotifier({
    'height': '180 cm',
    'weight': '75 kg',
    'bodyFat': '15%',
    'bmi': '23.1',
  });

  void clearData() {
    plans.clear();
    scheduledWorkouts.clear();
    statistics.value = {'totalVolume': 0.0};
    lastCompletedWorkout.value = null;
    userMetrics.value = {
      'height': '180 cm',
      'weight': '75 kg',
      'bodyFat': '15%',
      'bmi': '23.1',
    };
  }

  Future<void> saveUserMetrics(Map<String, String> metrics) async {
    userMetrics.value = metrics;
    if (apiClient.username != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'metrics_${apiClient.username}', json.encode(metrics));
    }
  }

  Future<void> loadUserMetrics() async {
    if (apiClient.username != null) {
      final prefs = await SharedPreferences.getInstance();
      final String? metricsString =
          prefs.getString('metrics_${apiClient.username}');
      if (metricsString != null) {
        try {
          final Map<String, dynamic> decoded = json.decode(metricsString);
          userMetrics.value = Map<String, String>.from(decoded);
        } catch (e) {
          print('Error parsing metrics: $e');
        }
      }
    }
  }

  Future<void> loadPlans() async {
    if (apiClient.isAuthenticated) {
      try {
        plans = await apiClient.getPlans();
      } catch (e) {
        print('Error loading plans: $e');
      }
    }
  }

  Future<void> addPlan(Plan plan) async {
    if (apiClient.isAuthenticated) {
      try {
        final newPlan = await apiClient.createPlan(plan);
        plans.add(newPlan);
      } catch (e) {
        print('Error creating plan: $e');
      }
    } else {
      plans.add(plan);
    }
  }

  Future<void> deletePlan(Plan plan) async {
    if (apiClient.isAuthenticated) {
      try {
        await apiClient.deletePlan(plan.id);
        plans.removeWhere((p) => p.id == plan.id);
        scheduledWorkouts.removeWhere((sw) => sw.planId == plan.id);
      } catch (e) {
        print('Error deleting plan: $e');
      }
    } else {
      plans.removeWhere((p) => p.id == plan.id);
      scheduledWorkouts.removeWhere((sw) => sw.planId == plan.id);
    }
  }

  void updatePlan(Plan updatedPlan) {
    // API update not implemented in client yet, assuming local for now or add to client
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

  Future<void> loadScheduledWorkouts() async {
    if (apiClient.isAuthenticated) {
      try {
        scheduledWorkouts = await apiClient.getScheduledWorkouts();
        _calculateStatistics();
      } catch (e) {
        print('Error loading scheduled workouts: $e');
      }
    }
  }

  void _calculateStatistics() {
    double totalVolume = 0;
    for (var workout in scheduledWorkouts) {
      if (workout.status == WorkoutStatus.completed) {
        for (var exercise in workout.exercises) {
          for (var set in exercise.sets) {
            totalVolume += set.reps * set.weight;
          }
        }
      }
    }
    statistics.value = {'totalVolume': totalVolume};
  }

  Future<ScheduledWorkout> scheduleWorkout(Plan plan, DateTime date) async {
    final newScheduledWorkout = ScheduledWorkout(
      id: const Uuid().v4(),
      date: date,
      planId: plan.id,
      planName: plan.name,
      exercises: plan.exercises,
    );

    if (apiClient.isAuthenticated) {
      try {
        final createdWorkout =
            await apiClient.scheduleWorkout(newScheduledWorkout);
        scheduledWorkouts.add(createdWorkout);
        return createdWorkout;
      } catch (e) {
        print('Error scheduling workout: $e');
        // Show error if possible (need context, but this method doesn't have it easily.
        // We will rely on the caller or just print for now, but completeWorkout has context)
        scheduledWorkouts.add(newScheduledWorkout);
        return newScheduledWorkout;
      }
    } else {
      scheduledWorkouts.add(newScheduledWorkout);
      return newScheduledWorkout;
    }
  }

  Future<void> completeWorkout(
      ScheduledWorkout workout, BuildContext context) async {
    workout.status = WorkoutStatus.completed;
    workout.time = DateFormat('HH:mm').format(DateTime.now());
    lastCompletedWorkout.value = workout;

    // Optimistic update stats
    _updateStats(workout, add: true);

    if (workout.planId.isEmpty) {
      print('Error: planId is empty for workout ${workout.id}');
      if (plans.isNotEmpty) {
        final matchingPlan = plans.firstWhere((p) => p.name == workout.planName,
            orElse: () => plans.first);
        workout.planId = matchingPlan.id;
        print(
            'Assigned planId ${workout.planId} from plan ${matchingPlan.name}');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Cannot complete workout: No plan associated.')),
          );
        }
        return;
      }
    }

    if (apiClient.isAuthenticated) {
      try {
        // Check if workout exists on server
        try {
          await apiClient.getScheduledWorkout(workout.id);
          // If exists, try to complete it
          await apiClient.completeWorkout(workout);
        } catch (e) {
          if (e is ApiException && e.statusCode == 404) {
            print('Workout not found on server (404). Creating it first...');
            await apiClient.scheduleWorkout(workout);
          } else if (e is ApiException && e.statusCode == 500) {
            print(
                'Server error (500) on update. Attempting Delete + Re-create fallback...');
            // Fallback: Delete and Re-create
            try {
              await apiClient.deleteScheduledWorkout(workout.id);
            } catch (deleteError) {
              print('Delete failed during fallback (ignoring): $deleteError');
            }
            await apiClient.scheduleWorkout(workout);
          } else {
            rethrow;
          }
        }

        // Success! Refresh data from API to ensure consistency
        await loadScheduledWorkouts();
      } catch (e) {
        print('Error completing workout: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sync failed: $e')),
          );
        }
      }
    }
  }

  void _updateStats(ScheduledWorkout workout, {required bool add}) {
    double volumeFromThisWorkout = 0;
    for (var exercise in workout.exercises) {
      for (var set in exercise.sets) {
        volumeFromThisWorkout += set.reps * set.weight;
      }
    }
    final currentStats = Map<String, double>.from(statistics.value);
    final currentTotal = currentStats['totalVolume'] ?? 0;
    currentStats['totalVolume'] = add
        ? currentTotal + volumeFromThisWorkout
        : currentTotal - volumeFromThisWorkout;
    statistics.value = currentStats;
  }

  void markAsCompleted(ScheduledWorkout workout, BuildContext context) {
    completeWorkout(workout, context);
  }

  Future<void> deleteScheduledWorkout(ScheduledWorkout workout) async {
    if (apiClient.isAuthenticated) {
      try {
        await apiClient.deleteScheduledWorkout(workout.id);
        scheduledWorkouts.removeWhere((sw) => sw.id == workout.id);
      } catch (e) {
        print('Error deleting scheduled workout: $e');
      }
    } else {
      scheduledWorkouts.removeWhere((sw) => sw.id == workout.id);
    }

    if (workout.status == WorkoutStatus.completed) {
      double volumeFromThisWorkout = 0;
      for (var exercise in workout.exercises) {
        for (var set in exercise.sets) {
          volumeFromThisWorkout += set.reps * set.weight;
        }
      }
      final currentStats = Map<String, double>.from(statistics.value);
      currentStats['totalVolume'] =
          (currentStats['totalVolume'] ?? 0) - volumeFromThisWorkout;
      statistics.value = currentStats;
    }
  }

  List<ScheduledWorkout> getWorkoutsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return scheduledWorkouts.where((workout) {
      final workoutDay =
          DateTime.utc(workout.date.year, workout.date.month, workout.date.day);
      return workoutDay == normalizedDay;
    }).toList();
  }
}
