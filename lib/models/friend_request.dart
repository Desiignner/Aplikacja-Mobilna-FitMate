class FriendRequest {
  final String id;
  final String senderId;
  final String senderName;
  final String? receiverId;
  final String? receiverName;
  final DateTime created;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.receiverId,
    this.receiverName,
    required this.created,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? json['fromUserId'] ?? '',
      senderName: json['senderName'] ??
          json['senderUsername'] ??
          json['username'] ??
          json['fromName'] ??
          'Unknown',
      receiverId: json['receiverId'] ?? json['recipientId'] ?? json['toUserId'],
      receiverName: json['receiverName'] ??
          json['receiverUsername'] ??
          json['recipientName'] ??
          json['username'] ??
          json['friendName'] ??
          json['toName'], // Removing debug string
      created: json['created'] != null
          ? DateTime.parse(json['created'])
          : (json['createdAtUtc'] != null
              ? DateTime.parse(json['createdAtUtc'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'created': created.toIso8601String(),
    };
  }
}
