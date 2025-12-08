class Goal {
  final String id;
  final String title;
  final String emoji;
  bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    required this.emoji,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'isCompleted': isCompleted,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      emoji: json['emoji'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
