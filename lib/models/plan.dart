import 'package:fitmate/models/exercise.dart';

class Plan {
  String id;
  String name;
  String type;
  String description;
  List<Exercise> exercises;

  Plan({
    required this.id,
    required this.name,
    this.type = '',
    this.description = '',
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];

  factory Plan.fromJson(Map<String, dynamic> json) {
    // Robust Name Extraction
    String extractName() {
      final keys = [
        'planName',
        'name',
        'plan_name',
        'workoutName',
        'workout_name',
        'title'
      ];
      for (var k in keys) {
        if (json[k] != null && json[k].toString().isNotEmpty)
          return json[k].toString();
      }
      return 'Unnamed Plan';
    }

    // Robust Description Extraction
    String extractDescription() {
      final keys = [
        'notes',
        'description',
        'planDescription',
        'plan_notes',
        'workoutDescription',
        'notes_description'
      ];
      for (var k in keys) {
        if (json[k] != null && json[k].toString().isNotEmpty)
          return json[k].toString();
      }
      return '';
    }

    // Robust Exercises Extraction
    List<Exercise> extractExercises() {
      final keys = [
        'exercises',
        'workout_exercises',
        'plan_exercises',
        'data',
        'workout_data'
      ];
      for (var k in keys) {
        if (json[k] != null && json[k] is List) {
          return (json[k] as List).map((e) => Exercise.fromJson(e)).toList();
        }
      }
      return [];
    }

    return Plan(
      id: json['id']?.toString() ?? json['planId']?.toString() ?? '',
      name: extractName(),
      description: extractDescription(),
      type: json['type'] ?? json['planType'] ?? json['category'] ?? 'Strength',
      exercises: extractExercises(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final map = {
      'planName': name,
      'type': type,
      'notes': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
    if (includeId) {
      map['id'] = id;
    }
    return map;
  }
}
