import 'package:fitmate/models/plan.dart';
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
  final Plan? planContent;

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
    this.planContent,
  });

  factory SharedPlan.fromJson(Map<String, dynamic> json) {
    // DEBUG LOG
    debugPrint('SharedPlan JSON: $json');

    // 1. Resolve Share ID (for detail endpoints)
    String resolveShareId(Map<String, dynamic> j) {
      final keys = [
        'id',
        'sharedPlanId',
        'sharingId',
        'recordId',
        'sharing_id',
        'shared_plan_id'
      ];
      for (var k in keys) {
        if (j[k] != null && j[k].toString().isNotEmpty) return j[k].toString();
      }
      return '';
    }

    // 2. Resolve name from potential nested objects
    String resolveName(Map<String, dynamic> j, List<String> primaryKeys,
        List<String> fallbackObjs) {
      final combinedKeys = [
        ...primaryKeys,
        'username',
        'name',
        'displayName',
        'full_name',
        'sender_username',
        'from_user_name',
        'userName',
        'senderName',
        'senderUsername',
        'fromName',
        'fromUserName'
      ];
      for (var k in combinedKeys) {
        if (j[k] != null &&
            j[k].toString().isNotEmpty &&
            j[k].toString().toLowerCase() != 'unknown') {
          return j[k].toString();
        }
      }
      final extendedFallbacks = [
        ...fallbackObjs,
        'user',
        'owner',
        'creator',
        'sender',
        'receiver',
        'targetUser',
        'from_user',
        'to_user'
      ];
      for (var objName in extendedFallbacks) {
        if (j[objName] != null && j[objName] is Map) {
          final obj = j[objName];
          final val = obj['username'] ??
              obj['userName'] ??
              obj['name'] ??
              obj['fullName'] ??
              obj['display_name'] ??
              obj['full_name'];
          if (val != null && val.toString().isNotEmpty) return val.toString();
        }
      }
      return 'Unknown';
    }

    // 3. Resolve ID from potential nested objects
    String resolveId(Map<String, dynamic> j, List<String> primaryKeys,
        List<String> fallbackObjs) {
      final combinedKeys = [
        ...primaryKeys,
        'id',
        'userId',
        'user_id',
        'friendId',
        'owner_id',
        'creator_id',
        'targetUserId',
        'toUserId'
      ];
      for (var k in combinedKeys) {
        if (j[k] != null && j[k].toString().isNotEmpty) {
          return j[k].toString();
        }
      }
      final extendedFallbacks = [
        ...fallbackObjs,
        'user',
        'owner',
        'creator',
        'sender',
        'receiver',
        'from_user',
        'to_user'
      ];
      for (var objName in extendedFallbacks) {
        if (j[objName] != null && j[objName] is Map) {
          final obj = j[objName];
          final val = obj['id'] ??
              obj['userId'] ??
              obj['user_id'] ??
              obj['friendId'] ??
              obj['owner_id'] ??
              obj['creator_id'];
          if (val != null && val.toString().isNotEmpty) return val.toString();
        }
      }
      return '';
    }

    // 4. Extract Plan ID
    String getPlanId(Map<String, dynamic> j) {
      final keys = [
        'planId',
        'plan_id',
        'originalPlanId',
        'original_plan_id',
        'basePlanId',
        'workoutId'
      ];
      for (var k in keys) {
        if (j[k] != null && j[k].toString().isNotEmpty) return j[k].toString();
      }
      for (var objName in ['plan', 'originalPlan', 'workout', 'basePlan']) {
        if (j[objName] != null && j[objName] is Map) {
          final obj = j[objName];
          final val = obj['id'] ??
              obj['planId'] ??
              obj['plan_id'] ??
              obj['base_plan_id'] ??
              obj['workoutId'];
          if (val != null && val.toString().isNotEmpty) return val.toString();
        }
      }
      return '';
    }

    final pId = getPlanId(json);

    // 5. Extract Plan Content if pre-loaded
    Plan? getPlanContent(Map<String, dynamic> j) {
      for (var objName in [
        'plan',
        'originalPlan',
        'workout',
        'plan_data',
        'details',
        'content',
        'workout_content'
      ]) {
        if (j[objName] != null && j[objName] is Map<String, dynamic>) {
          final obj = j[objName];
          if (obj['exercises'] != null ||
              obj['planName'] != null ||
              obj['name'] != null ||
              obj['workout_exercises'] != null) {
            try {
              return Plan.fromJson(obj);
            } catch (_) {}
          }
        }
      }
      return null;
    }

    return SharedPlan(
      id: resolveShareId(json),
      planId: pId,
      planName: json['planName'] ??
          json['plan']?['planName'] ??
          json['plan']?['name'] ??
          json['workout']?['name'] ??
          'Unknown Plan',
      senderId: resolveId(
          json,
          ['senderId', 'fromUserId', 'from_user_id', 'sender_id', 'sharedById'],
          ['fromUser', 'sender']),
      senderName: resolveName(json, [
        'sharedByName',
        'senderName',
        'senderUsername',
        'fromName',
        'fromUserName',
        'from_user_name',
        'sender_name'
      ], [
        'fromUser',
        'sender'
      ]),
      receiverId: resolveId(json, [
        'receiverId',
        'toUserId',
        'to_user_id',
        'receiver_id',
        'sharedWithId'
      ], [
        'toUser',
        'receiver',
        'targetUser'
      ]),
      receiverName: resolveName(json, [
        'sharedWithName',
        'receiverName',
        'receiverUsername',
        'toName',
        'to_user_name',
        'receiver_name'
      ], [
        'toUser',
        'receiver',
        'targetUser'
      ]),
      status: json['status'] ?? 'Pending',
      created: json['sharedAtUtc'] != null
          ? DateTime.parse(json['sharedAtUtc'])
          : (json['created'] != null
              ? DateTime.parse(json['created'])
              : (json['createdAtUtc'] != null
                  ? DateTime.parse(json['createdAtUtc'])
                  : DateTime.now())),
      planContent: getPlanContent(json),
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
      'plan': planContent?.toJson(),
    };
  }
}
