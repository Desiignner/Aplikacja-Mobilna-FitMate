import 'package:fitmate/models/exercise.dart';

enum WorkoutStatus { planned, completed }

class ScheduledWorkout {
  int id;
  DateTime date;
  String time;
  int planId;
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
}