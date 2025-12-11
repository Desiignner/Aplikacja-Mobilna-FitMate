class Friend {
  final String id;
  final String username;
  final String? fullName;

  Friend({
    required this.id,
    required this.username,
    this.fullName,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? json['friendId'] ?? json['userId'] ?? '',
      username: json['username'] ?? json['userName'] ?? 'Unknown',
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
    };
  }
}
