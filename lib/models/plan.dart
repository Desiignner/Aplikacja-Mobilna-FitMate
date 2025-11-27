import 'package:fitmate/models/exercise.dart';

class Plan {
  int id;
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
}