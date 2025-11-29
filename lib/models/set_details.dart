class SetDetails {
  int reps;
  double weight;

  SetDetails({this.reps = 10, this.weight = 0.0});

  factory SetDetails.fromJson(Map<String, dynamic> json) {
    return SetDetails(
      reps: json['reps'] ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }
}
