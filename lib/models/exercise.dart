import 'package:fitmate/models/set_details.dart';

class Exercise {
  String name;
  int rest;
  List<SetDetails> sets;

  Exercise({
    this.name = '',
    this.rest = 60,
    List<SetDetails>? sets,
  }) : sets = sets ?? [];

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      rest: json['rest'] ?? 60,
      sets: (json['sets'] as List<dynamic>?)
          ?.map((e) => SetDetails.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rest': rest,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }
}
