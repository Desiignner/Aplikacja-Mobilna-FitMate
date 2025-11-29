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
    return Plan(
      id: json['id'] ?? '',
      name: json['planName'] ?? '', // API uses planName
      type: json['type'] ?? '',
      description: json['notes'] ?? '', // API uses notes
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planName': name,
      'type': type,
      'notes': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
