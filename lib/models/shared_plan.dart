import 'package:flutter/foundation.dart';

class SharedPlan {
  final String id;
  final String planId;
  final String planName;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String status; // 'Pending', 'Accepted', etc.
  final DateTime created;

  SharedPlan({
    required this.id,
    required this.planId,
    required this.planName,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.status,
    required this.created,
  });

  factory SharedPlan.fromJson(Map<String, dynamic> json) {
    // DEBUG LOG
    debugPrint('SharedPlan JSON: $json');
    return SharedPlan(
      id: json['id'] ?? '',
      planId: json['planId'] ?? '',
      planName: json['planName'] ?? 'Unknown Plan',
      senderId: json['senderId'] ?? json['fromUserId'] ?? '',
      senderName: json['senderName'] ??
          json['senderUsername'] ??
          json['fromName'] ??
          json['fromUserName'] ??
          'Unknown',
      receiverId: json['receiverId'] ?? json['toUserId'] ?? '',
      receiverName: json['receiverName'] ??
          json['receiverUsername'] ??
          json['toName'] ??
          'Unknown',
      status: json['status'] ?? 'Pending',
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
      'planId': planId,
      'planName': planName,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'status': status,
      'created': created.toIso8601String(),
    };
  }
}
