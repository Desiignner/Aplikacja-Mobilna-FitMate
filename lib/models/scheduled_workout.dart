import 'package:fitmate/models/exercise.dart';

enum WorkoutStatus { planned, completed }

class ScheduledWorkout {
  String id;
  DateTime date;
  String time;
  String planId;
  String planName;
  List<Exercise> exercises;
  WorkoutStatus status;

  ScheduledWorkout({
    required this.id,
    required this.date,
    required this.planId,
    required this.planName,
    required this.exercises,
    this.time = '',
    this.status = WorkoutStatus.planned,
  });

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) {
    return ScheduledWorkout(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      planId: json['planId'] ?? '',
      planName: json['planName'] ?? '',
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromJson(e))
              .toList() ??
          [],
      time: json['time'] ?? '',
      status: WorkoutStatus.values.firstWhere(
          (e) => e.toString() == 'WorkoutStatus.${json['status']}',
          orElse: () => WorkoutStatus.planned),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'planId': planId,
      'planName': planName,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'time': time,
      'status': status.toString().split('.').last,
    };
  }
}
