import 'dart:convert';
import 'package:fitmate/api/api_client.dart';
import 'package:fitmate/models/plan.dart';
import 'package:fitmate/models/scheduled_workout.dart';
import 'package:fitmate/models/goal.dart';
import 'package:fitmate/models/friend.dart';
import 'package:fitmate/models/friend_request.dart';
import 'package:fitmate/models/shared_plan.dart';
import 'package:fitmate/api/models/models.dart';
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

  // Goals
  final ValueNotifier<List<Goal>> goals = ValueNotifier([
    Goal(id: '1', title: 'Sleep 8h', emoji: '💤', isCompleted: false),
  ]);

  // Friends
  final ValueNotifier<List<Friend>> friends = ValueNotifier([]);
  final ValueNotifier<List<FriendRequest>> incomingRequests = ValueNotifier([]);
  final ValueNotifier<List<FriendRequest>> outgoingRequests = ValueNotifier([]);

  final ValueNotifier<List<SharedPlan>> sharedPlans = ValueNotifier([]);
  final ValueNotifier<List<SharedPlan>> sharedByMePlans = ValueNotifier([]);
  final ValueNotifier<List<SharedPlan>> pendingSharedPlans = ValueNotifier([]);
  final ValueNotifier<List<SharedPlan>> sentSharedPlans = ValueNotifier([]);

  void addGoal(String title, String emoji) {
    final newGoal = Goal(
      id: const Uuid().v4(),
      title: title,
      emoji: emoji,
    );
    final updatedGoals = [...goals.value, newGoal];
    goals.value = updatedGoals;
    _cacheGoals(updatedGoals);
  }

  void toggleGoalCompletion(String id) {
    final currentGoals = List<Goal>.from(goals.value);
    final index = currentGoals.indexWhere((g) => g.id == id);
    if (index != -1) {
      currentGoals[index].isCompleted = !currentGoals[index].isCompleted;
      goals.value = currentGoals;
      _cacheGoals(currentGoals);
    }
  }

  void removeGoal(String id) {
    final currentGoals = List<Goal>.from(goals.value);
    currentGoals.removeWhere((g) => g.id == id);
    goals.value = currentGoals;
    _cacheGoals(currentGoals);
  }

  Future<void> loadGoals() async {
    await _loadGoalsFromCache();
  }

  Future<void> _loadGoalsFromCache() async {
    try {
      if (apiClient.username != null) {
        final prefs = await SharedPreferences.getInstance();
        final String? goalsString =
            prefs.getString('goals_${apiClient.username}');
        if (goalsString != null) {
          final List<dynamic> decoded = json.decode(goalsString);
          final loadedGoals = decoded.map((g) => Goal.fromJson(g)).toList();
          goals.value = loadedGoals;
        }
      }
    } catch (e) {
      debugPrint('Error loading cached goals: $e');
    }
  }

  Future<void> _cacheGoals(List<Goal> currentGoals) async {
    try {
      if (apiClient.username != null) {
        final prefs = await SharedPreferences.getInstance();
        final String encoded =
            json.encode(currentGoals.map((g) => g.toJson()).toList());
        await prefs.setString('goals_${apiClient.username}', encoded);
      }
    } catch (e) {
      debugPrint('Error caching goals: $e');
    }
  }

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
    goals.value = [
      Goal(id: '1', title: 'Sleep 8h', emoji: '💤', isCompleted: false),
    ];
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
          debugPrint('Error parsing metrics: $e');
        }
      }
    }
  }

  Future<void> loadPlans() async {
    if (apiClient.isAuthenticated) {
      try {
        plans = await apiClient.getPlans();
      } catch (e) {
        debugPrint('Error loading plans: $e');
      }
    }
  }

  Future<Plan?> getPlan(String planId) async {
    if (apiClient.isAuthenticated) {
      try {
        return await apiClient.getPlan(planId);
      } catch (e) {
        debugPrint('Error loading plan $planId: $e');
      }
    }
    return null;
  }

  Future<void> addPlan(Plan plan) async {
    if (apiClient.isAuthenticated) {
      try {
        final newPlan = await apiClient.createPlan(plan);
        plans.add(newPlan);
      } catch (e) {
        debugPrint('Error creating plan: $e');
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
        debugPrint('Error deleting plan: $e');
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
        // Try to load from cache first for immediate feedback
        await _loadLastWorkoutFromCache();

        scheduledWorkouts = await apiClient.getScheduledWorkouts();
        _calculateStatistics();

        _recalculateLastCompletedWorkout();
      } catch (e) {
        debugPrint('Error loading scheduled workouts: $e');
      }
    }
  }

  Future<void> _cacheLastWorkout(ScheduledWorkout workout) async {
    try {
      if (apiClient.username != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_workout_${apiClient.username}',
            json.encode(workout.toJson()));
      }
    } catch (e) {
      debugPrint('Error caching last workout: $e');
    }
  }

  Future<void> _loadLastWorkoutFromCache() async {
    try {
      if (apiClient.username != null && lastCompletedWorkout.value == null) {
        final prefs = await SharedPreferences.getInstance();
        final String? jsonStr =
            prefs.getString('last_workout_${apiClient.username}');
        if (jsonStr != null) {
          lastCompletedWorkout.value =
              ScheduledWorkout.fromJson(json.decode(jsonStr));
        }
      }
    } catch (e) {
      debugPrint('Error loading cached last workout: $e');
    }
  }

  void _calculateStatistics() {
    double totalVolume = 0;
    final now = DateTime.now();
    for (var workout in scheduledWorkouts) {
      if (workout.status == WorkoutStatus.completed &&
          workout.date.month == now.month &&
          workout.date.year == now.year) {
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
        debugPrint('Error scheduling workout: $e');
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
    _cacheLastWorkout(workout);

    // Optimistic update stats
    _updateStats(workout, add: true);

    if (workout.planId.isEmpty) {
      debugPrint('Error: planId is empty for workout ${workout.id}');
      if (plans.isNotEmpty) {
        final matchingPlan = plans.firstWhere((p) => p.name == workout.planName,
            orElse: () => plans.first);
        workout.planId = matchingPlan.id;
        debugPrint(
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
            debugPrint(
                'Workout not found on server (404). Creating it first...');
            await apiClient.scheduleWorkout(workout);
          } else if (e is ApiException && e.statusCode == 500) {
            debugPrint(
                'Server error (500) on update. Attempting Delete + Re-create fallback...');
            // Fallback: Delete and Re-create
            try {
              await apiClient.deleteScheduledWorkout(workout.id);
            } catch (deleteError) {
              debugPrint(
                  'Delete failed during fallback (ignoring): $deleteError');
            }
            await apiClient.scheduleWorkout(workout);
          } else {
            rethrow;
          }
        }

        // Success! Refresh data from API to ensure consistency
        await loadScheduledWorkouts();
      } catch (e) {
        debugPrint('Error completing workout: $e');
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
        debugPrint('Error deleting scheduled workout: $e');
      }
    } else {
      scheduledWorkouts.removeWhere((sw) => sw.id == workout.id);
    }

    if (workout.status == WorkoutStatus.completed) {
      // Update Statistics
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

      // Update Last Completed Workout
      _recalculateLastCompletedWorkout();
    }
  }

  void _recalculateLastCompletedWorkout() {
    final completed = scheduledWorkouts
        .where((w) => w.status == WorkoutStatus.completed)
        .toList();

    if (completed.isNotEmpty) {
      completed.sort((a, b) {
        final dateComp = b.date.compareTo(a.date);
        if (dateComp != 0) return dateComp;
        return b.time.compareTo(a.time);
      });
      final newest = completed.first;
      lastCompletedWorkout.value = newest;
      _cacheLastWorkout(newest);
    } else {
      lastCompletedWorkout.value = null;
      // Ideally clear cache too, but _cacheLastWorkout expects a workout.
      // I should update _cacheLastWorkout to handle null or add _clearCachedLastWorkout.
      // For now, if null, we just don't cache anything (stale cache might exist).
      // I will add a clear method implementation inline here or update the cache method.
      _clearCachedLastWorkout();
    }
  }

  Future<void> _clearCachedLastWorkout() async {
    try {
      if (apiClient.username != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('last_workout_${apiClient.username}');
      }
    } catch (e) {
      debugPrint('Error clearing cached last workout: $e');
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

  // Friends Methods
  Future<void> loadFriendsAndRequests() async {
    if (!apiClient.isAuthenticated) return;
    try {
      friends.value = await apiClient.getFriends();
      incomingRequests.value = await apiClient.getIncomingRequests();
      outgoingRequests.value = await apiClient.getOutgoingRequests();
    } catch (e) {
      debugPrint('Error loading friends data: $e');
    }
  }

  Future<void> sendFriendRequest(String username) async {
    await apiClient.sendFriendRequest(username);
    await loadFriendsAndRequests();
  }

  Future<void> respondToFriendRequest(String requestId, bool accept) async {
    await apiClient.respondToFriendRequest(requestId, accept);
    await loadFriendsAndRequests();
  }

  Future<void> removeFriend(String friendUserId) async {
    await apiClient.removeFriend(friendUserId);
    await loadFriendsAndRequests();
  }

  // Body Measurements
  final ValueNotifier<List<BodyMeasurementDto>> bodyMeasurements =
      ValueNotifier([]);
  final ValueNotifier<BodyMetricsStatsDto?> bodyMetricsStats =
      ValueNotifier(null);
  final ValueNotifier<List<BodyMetricsProgressDto>> bodyMetricsProgress =
      ValueNotifier([]);
  final ValueNotifier<double?> targetWeight = ValueNotifier(null);

  Future<void> loadBodyMeasurements() async {
    if (!apiClient.isAuthenticated) return;
    try {
      await Future.wait([
        _loadMeasurementsList(),
        _loadStats(),
        _loadProgress(),
        _loadTargetWeight(),
      ]);
      _updateProfileMetrics();
    } catch (e) {
      debugPrint('Error loading body measurements data: $e');
    }
  }

  Future<void> _loadMeasurementsList() async {
    try {
      bodyMeasurements.value = await apiClient.getBodyMeasurements();
    } catch (e) {
      debugPrint('Error list: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      bodyMetricsStats.value = await apiClient.getBodyMetricsStats();
    } catch (e) {
      debugPrint('Error stats: $e');
    }
  }

  Future<void> _loadProgress() async {
    try {
      bodyMetricsProgress.value = await apiClient.getBodyMetricsProgress();
    } catch (e) {
      debugPrint('Error progress: $e');
    }
  }

  Future<void> _loadTargetWeight() async {
    if (apiClient.username != null) {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getDouble('target_weight_${apiClient.username}');
      targetWeight.value = val;
    }
  }

  Future<void> saveTargetWeight(double weight) async {
    if (apiClient.username != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('target_weight_${apiClient.username}', weight);
      targetWeight.value = weight;
    }
  }

  void _updateProfileMetrics() {
    if (bodyMeasurements.value.isNotEmpty) {
      bodyMeasurements.value
          .sort((a, b) => b.measuredAtUtc.compareTo(a.measuredAtUtc));
      final latest = bodyMeasurements.value.first;

      userMetrics.value = {
        'height': '${latest.heightCm} cm',
        'weight': '${latest.weightKg} kg',
        'bodyFat': latest.bodyFatPercentage != null
            ? '${latest.bodyFatPercentage}%'
            : '-',
        'bmi': latest.bmi.toStringAsFixed(1),
      };
    }
  }

  Future<void> saveMeasurement(CreateBodyMeasurementDto measurement) async {
    await apiClient.saveBodyMeasurement(measurement);
    await loadBodyMeasurements();
  }

  Future<void> deleteMeasurement(String id) async {
    await apiClient.deleteBodyMeasurement(id);
    await loadBodyMeasurements();
  }

  // Shared Plans Methods
  Future<void> loadSharedPlans() async {
    if (!apiClient.isAuthenticated) return;
    try {
      sharedPlans.value = await apiClient.getSharedPlansWithMe();
      sharedByMePlans.value = await apiClient.getSharedPlansByMe();
      pendingSharedPlans.value = await apiClient.getPendingSharedPlans();
      sentSharedPlans.value = await apiClient.getSentPendingSharedPlans();
    } catch (e) {
      debugPrint('Error loading shared plans: $e');
    }
  }

  Future<void> sharePlan(String planId, String friendId) async {
    await apiClient.sharePlan(planId, friendId);
    await loadSharedPlans();
  }

  Future<void> respondToSharedPlan(String sharedPlanId, bool accept) async {
    await apiClient.respondToSharedPlan(sharedPlanId, accept);
    await loadSharedPlans();
  }

  Future<void> removeSharedPlan(String sharedPlanId) async {
    await apiClient.removeSharedPlan(sharedPlanId);
    await loadSharedPlans();
  }
}
