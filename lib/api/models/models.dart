import 'dart:convert';

// Auth
class AuthResponse {
  final String? accessToken;
  final DateTime expiresAtUtc;
  final String? refreshToken;

  AuthResponse({
    this.accessToken,
    required this.expiresAtUtc,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      expiresAtUtc: DateTime.parse(json['expiresAtUtc']),
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expiresAtUtc': expiresAtUtc.toIso8601String(),
      'refreshToken': refreshToken,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String userName;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'userName': userName,
    };
  }
}

class LoginRequest {
  final String userNameOrEmail;
  final String password;

  LoginRequest({
    required this.userNameOrEmail,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'userNameOrEmail': userNameOrEmail,
      'password': password,
    };
  }
}

class RefreshRequestDto {
  final String refreshToken;

  RefreshRequestDto({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

class LogoutRequestDto {
  final String refreshToken;

  LogoutRequestDto({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

// Error Handling
class ProblemDetails {
  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String? instance;
  final Map<String, dynamic> additionalProperties;

  ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
    this.additionalProperties = const {},
  });

  factory ProblemDetails.fromJson(Map<String, dynamic> json) {
    return ProblemDetails(
      type: json['type'],
      title: json['title'],
      status: json['status'],
      detail: json['detail'],
      instance: json['instance'],
      additionalProperties: Map<String, dynamic>.from(json)
        ..remove('type')
        ..remove('title')
        ..remove('status')
        ..remove('detail')
        ..remove('instance'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'status': status,
      'detail': detail,
      'instance': instance,
      ...additionalProperties,
    };
  }
}

// Analytics
class OverviewDto {
  final double totalVolume;
  final double avgIntensity;
  final int sessionsCount;
  final double adherencePct;
  final int newPrs;

  OverviewDto({
    required this.totalVolume,
    required this.avgIntensity,
    required this.sessionsCount,
    required this.adherencePct,
    required this.newPrs,
  });

  factory OverviewDto.fromJson(Map<String, dynamic> json) {
    return OverviewDto(
      totalVolume: json['totalVolume']?.toDouble() ?? 0.0,
      avgIntensity: json['avgIntensity']?.toDouble() ?? 0.0,
      sessionsCount: json['sessionsCount'] ?? 0,
      adherencePct: json['adherencePct']?.toDouble() ?? 0.0,
      newPrs: json['newPrs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalVolume': totalVolume,
      'avgIntensity': avgIntensity,
      'sessionsCount': sessionsCount,
      'adherencePct': adherencePct,
      'newPrs': newPrs,
    };
  }
}

class TimePointDto {
  final String? period;
  final double value;
  final String? exerciseName;

  TimePointDto({
    this.period,
    required this.value,
    this.exerciseName,
  });

  factory TimePointDto.fromJson(Map<String, dynamic> json) {
    return TimePointDto(
      period: json['period'],
      value: json['value']?.toDouble() ?? 0.0,
      exerciseName: json['exerciseName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'value': value,
      'exerciseName': exerciseName,
    };
  }
}

class E1rmPointDto {
  final DateTime day;
  final double e1Rm;
  final String? sessionId;

  E1rmPointDto({
    required this.day,
    required this.e1Rm,
    this.sessionId,
  });

  factory E1rmPointDto.fromJson(Map<String, dynamic> json) {
    return E1rmPointDto(
      day: DateTime.parse(json['day']),
      e1Rm: json['e1Rm']?.toDouble() ?? 0.0,
      sessionId: json['sessionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String().substring(0, 10), // Date only
      'e1Rm': e1Rm,
      'sessionId': sessionId,
    };
  }
}

class AdherenceDto {
  final int planned;
  final int completed;
  final int missed;
  final double adherencePct;

  AdherenceDto({
    required this.planned,
    required this.completed,
    required this.missed,
    required this.adherencePct,
  });

  factory AdherenceDto.fromJson(Map<String, dynamic> json) {
    return AdherenceDto(
      planned: json['planned'] ?? 0,
      completed: json['completed'] ?? 0,
      missed: json['missed'] ?? 0,
      adherencePct: json['adherencePct']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planned': planned,
      'completed': completed,
      'missed': missed,
      'adherencePct': adherencePct,
    };
  }
}

class PlanVsActualItemDto {
  final String? exerciseName;
  final int setNumber;
  final int repsPlanned;
  final double weightPlanned;
  final int? repsDone;
  final double? weightDone;
  final double? rpe;
  final bool? isFailure;
  final bool isExtra;
  final int repsDiff;
  final double weightDiff;

  PlanVsActualItemDto({
    this.exerciseName,
    required this.setNumber,
    required this.repsPlanned,
    required this.weightPlanned,
    this.repsDone,
    this.weightDone,
    this.rpe,
    this.isFailure,
    required this.isExtra,
    required this.repsDiff,
    required this.weightDiff,
  });

  factory PlanVsActualItemDto.fromJson(Map<String, dynamic> json) {
    return PlanVsActualItemDto(
      exerciseName: json['exerciseName'],
      setNumber: json['setNumber'] ?? 0,
      repsPlanned: json['repsPlanned'] ?? 0,
      weightPlanned: json['weightPlanned']?.toDouble() ?? 0.0,
      repsDone: json['repsDone'],
      weightDone: json['weightDone']?.toDouble(),
      rpe: json['rpe']?.toDouble(),
      isFailure: json['isFailure'],
      isExtra: json['isExtra'] ?? false,
      repsDiff: json['repsDiff'] ?? 0,
      weightDiff: json['weightDiff']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'setNumber': setNumber,
      'repsPlanned': repsPlanned,
      'weightPlanned': weightPlanned,
      'repsDone': repsDone,
      'weightDone': weightDone,
      'rpe': rpe,
      'isFailure': isFailure,
      'isExtra': isExtra,
      'repsDiff': repsDiff,
      'weightDiff': weightDiff,
    };
  }
}


// Body Metrics
class CreateBodyMeasurementDto {
  final double weightKg;
  final int heightCm;
  final double? bodyFatPercentage;
  final int? chestCm;
  final int? waistCm;
  final int? hipsCm;
  final int? bicepsCm;
  final int? thighsCm;
  final String? notes;

  CreateBodyMeasurementDto({
    required this.weightKg,
    required this.heightCm,
    this.bodyFatPercentage,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.bicepsCm,
    this.thighsCm,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'weightKg': weightKg,
      'heightCm': heightCm,
      'bodyFatPercentage': bodyFatPercentage,
      'chestCm': chestCm,
      'waistCm': waistCm,
      'hipsCm': hipsCm,
      'bicepsCm': bicepsCm,
      'thighsCm': thighsCm,
      'notes': notes,
    };
  }
}

class BodyMeasurementDto {
  final String id;
  final DateTime measuredAtUtc;
  final double weightKg;
  final int heightCm;
  final double bmi;
  final double? bodyFatPercentage;
  final int? chestCm;
  final int? waistCm;
  final int? hipsCm;
  final int? bicepsCm;
  final int? thighsCm;
  final String? notes;

  BodyMeasurementDto({
    required this.id,
    required this.measuredAtUtc,
    required this.weightKg,
    required this.heightCm,
    required this.bmi,
    this.bodyFatPercentage,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.bicepsCm,
    this.thighsCm,
    this.notes,
  });

  factory BodyMeasurementDto.fromJson(Map<String, dynamic> json) {
    return BodyMeasurementDto(
      id: json['id'],
      measuredAtUtc: DateTime.parse(json['measuredAtUtc']),
      weightKg: json['weightKg']?.toDouble() ?? 0.0,
      heightCm: json['heightCm'] ?? 0,
      bmi: json['bmi']?.toDouble() ?? 0.0,
      bodyFatPercentage: json['bodyFatPercentage']?.toDouble(),
      chestCm: json['chestCm'],
      waistCm: json['waistCm'],
      hipsCm: json['hipsCm'],
      bicepsCm: json['bicepsCm'],
      thighsCm: json['thighsCm'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'measuredAtUtc': measuredAtUtc.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'bmi': bmi,
      'bodyFatPercentage': bodyFatPercentage,
      'chestCm': chestCm,
      'waistCm': waistCm,
      'hipsCm': hipsCm,
      'bicepsCm': bicepsCm,
      'thighsCm': thighsCm,
      'notes': notes,
    };
  }
}

class BodyMetricsProgressDto {
  final DateTime date;
  final double weightKg;
  final double bmi;

  BodyMetricsProgressDto({
    required this.date,
    required this.weightKg,
    required this.bmi,
  });

  factory BodyMetricsProgressDto.fromJson(Map<String, dynamic> json) {
    return BodyMetricsProgressDto(
      date: DateTime.parse(json['date']),
      weightKg: json['weightKg']?.toDouble() ?? 0.0,
      bmi: json['bmi']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'bmi': bmi,
    };
  }
}

class BodyMetricsStatsDto {
  final double? currentWeightKg;
  final double? currentBMI;
  final String? bmiCategory;
  final double? weightChangeLast30Days;
  final double? lowestWeight;
  final double? highestWeight;
  final int totalMeasurements;

  BodyMetricsStatsDto({
    this.currentWeightKg,
    this.currentBMI,
    this.bmiCategory,
    this.weightChangeLast30Days,
    this.lowestWeight,
    this.highestWeight,
    required this.totalMeasurements,
  });

  factory BodyMetricsStatsDto.fromJson(Map<String, dynamic> json) {
    return BodyMetricsStatsDto(
      currentWeightKg: json['currentWeightKg']?.toDouble(),
      currentBMI: json['currentBMI']?.toDouble(),
      bmiCategory: json['bmiCategory'],
      weightChangeLast30Days: json['weightChangeLast30Days']?.toDouble(),
      lowestWeight: json['lowestWeight']?.toDouble(),
      highestWeight: json['highestWeight']?.toDouble(),
      totalMeasurements: json['totalMeasurements'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentWeightKg': currentWeightKg,
      'currentBMI': currentBMI,
      'bmiCategory': bmiCategory,
      'weightChangeLast30Days': weightChangeLast30Days,
      'lowestWeight': lowestWeight,
      'highestWeight': highestWeight,
      'totalMeasurements': totalMeasurements,
    };
  }
}

// Friends
class FriendDto {
  final String userId;
  final String userName;

  FriendDto({
    required this.userId,
    required this.userName,
  });

  factory FriendDto.fromJson(Map<String, dynamic> json) {
    return FriendDto(
      userId: json['userId'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
    };
  }
}

class FriendRequestDto {
  final String id;
  final String fromUserId;
  final String fromName;
  final String toUserId;
  final String toName;
  final String status;
  final DateTime createdAtUtc;
  final DateTime? respondedAtUtc;

  FriendRequestDto({
    required this.id,
    required this.fromUserId,
    required this.fromName,
    required this.toUserId,
    required this.toName,
    required this.status,
    required this.createdAtUtc,
    this.respondedAtUtc,
  });

  factory FriendRequestDto.fromJson(Map<String, dynamic> json) {
    return FriendRequestDto(
      id: json['id'],
      fromUserId: json['fromUserId'],
      fromName: json['fromName'],
      toUserId: json['toUserId'],
      toName: json['toName'],
      status: json['status'],
      createdAtUtc: DateTime.parse(json['createdAtUtc']),
      respondedAtUtc: json['respondedAtUtc'] != null ? DateTime.parse(json['respondedAtUtc']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromName': fromName,
      'toUserId': toUserId,
      'toName': toName,
      'status': status,
      'createdAtUtc': createdAtUtc.toIso8601String(),
      'respondedAtUtc': respondedAtUtc?.toIso8601String(),
    };
  }
}

class RespondFriendRequest {
  final bool accept;

  RespondFriendRequest({required this.accept});

  Map<String, dynamic> toJson() {
    return {
      'accept': accept,
    };
  }
}

// Friends Workouts
class FriendScheduledWorkoutDto {
  final String scheduledId;
  final String userId;
  final String? userName;
  final String? fullName;
  final DateTime date;
  final String? time;
  final String? planName;
  final String? status;

  FriendScheduledWorkoutDto({
    required this.scheduledId,
    required this.userId,
    this.userName,
    this.fullName,
    required this.date,
    this.time,
    this.planName,
    this.status,
  });

  factory FriendScheduledWorkoutDto.fromJson(Map<String, dynamic> json) {
    return FriendScheduledWorkoutDto(
      scheduledId: json['scheduledId'],
      userId: json['userId'],
      userName: json['userName'],
      fullName: json['fullName'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      planName: json['planName'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduledId': scheduledId,
      'userId': userId,
      'userName': userName,
      'fullName': fullName,
      'date': date.toIso8601String().substring(0, 10), // Date only
      'time': time,
      'planName': planName,
      'status': status,
    };
  }
}

class FriendWorkoutSessionDto {
  final String sessionId;
  final String scheduledId;
  final String userId;
  final String? userName;
  final String? fullName;
  final String? planName;
  final DateTime startedAtUtc;
  final DateTime? completedAtUtc;
  final int? durationSec;
  final String? status;

  FriendWorkoutSessionDto({
    required this.sessionId,
    required this.scheduledId,
    required this.userId,
    this.userName,
    this.fullName,
    this.planName,
    required this.startedAtUtc,
    this.completedAtUtc,
    this.durationSec,
    this.status,
  });

  factory FriendWorkoutSessionDto.fromJson(Map<String, dynamic> json) {
    return FriendWorkoutSessionDto(
      sessionId: json['sessionId'],
      scheduledId: json['scheduledId'],
      userId: json['userId'],
      userName: json['userName'],
      fullName: json['fullName'],
      planName: json['planName'],
      startedAtUtc: DateTime.parse(json['startedAtUtc']),
      completedAtUtc: json['completedAtUtc'] != null ? DateTime.parse(json['completedAtUtc']) : null,
      durationSec: json['durationSec'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'scheduledId': scheduledId,
      'userId': userId,
      'userName': userName,
      'fullName': fullName,
      'planName': planName,
      'startedAtUtc': startedAtUtc.toIso8601String(),
      'completedAtUtc': completedAtUtc?.toIso8601String(),
      'durationSec': durationSec,
      'status': status,
    };
  }
}


// Plans
class SetDto {
  final int reps;
  final double weight;

  SetDto({
    required this.reps,
    required this.weight,
  });

  factory SetDto.fromJson(Map<String, dynamic> json) {
    return SetDto(
      reps: json['reps'] ?? 0,
      weight: json['weight']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }
}

class ExerciseDto {
  final String name;
  final int rest;
  final List<SetDto>? sets;

  ExerciseDto({
    required this.name,
    required this.rest,
    this.sets,
  });

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    return ExerciseDto(
      name: json['name'],
      rest: json['rest'] ?? 0,
      sets: (json['sets'] as List<dynamic>?)
          ?.map((e) => SetDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rest': rest,
      'sets': sets?.map((e) => e.toJson()).toList(),
    };
  }
}

class CreatePlanDto {
  final String planName;
  final String type;
  final String? notes;
  final List<ExerciseDto>? exercises;

  CreatePlanDto({
    required this.planName,
    required this.type,
    this.notes,
    this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'planName': planName,
      'type': type,
      'notes': notes,
      'exercises': exercises?.map((e) => e.toJson()).toList(),
    };
  }
}

class PlanDto {
  final String id;
  final String? planName;
  final String? type;
  final String? notes;
  final List<ExerciseDto>? exercises;

  PlanDto({
    required this.id,
    this.planName,
    this.type,
    this.notes,
    this.exercises,
  });

  factory PlanDto.fromJson(Map<String, dynamic> json) {
    return PlanDto(
      id: json['id'],
      planName: json['planName'],
      type: json['type'],
      notes: json['notes'],
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => ExerciseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planName': planName,
      'type': type,
      'notes': notes,
      'exercises': exercises?.map((e) => e.toJson()).toList(),
    };
  }
}

class RespondSharedPlanRequest {
  final bool accept;

  RespondSharedPlanRequest({required this.accept});

  Map<String, dynamic> toJson() {
    return {
      'accept': accept,
    };
  }
}

class SharedPlanDto {
  final String id;
  final String planId;
  final String? planName;
  final String? sharedByName;
  final String? sharedWithName;
  final DateTime sharedAtUtc;
  final String? status;
  final DateTime? respondedAtUtc;

  SharedPlanDto({
    required this.id,
    required this.planId,
    this.planName,
    this.sharedByName,
    this.sharedWithName,
    required this.sharedAtUtc,
    this.status,
    this.respondedAtUtc,
  });

  factory SharedPlanDto.fromJson(Map<String, dynamic> json) {
    return SharedPlanDto(
      id: json['id'],
      planId: json['planId'],
      planName: json['planName'],
      sharedByName: json['sharedByName'],
      sharedWithName: json['sharedWithName'],
      sharedAtUtc: DateTime.parse(json['sharedAtUtc']),
      status: json['status'],
      respondedAtUtc: json['respondedAtUtc'] != null ? DateTime.parse(json['respondedAtUtc']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'planName': planName,
      'sharedByName': sharedByName,
      'sharedWithName': sharedWithName,
      'sharedAtUtc': sharedAtUtc.toIso8601String(),
      'status': status,
      'respondedAtUtc': respondedAtUtc?.toIso8601String(),
    };
  }
}

// Scheduled
class CreateScheduledDto {
  final String date;
  final String? time;
  final String planId;
  final String? planName;
  final String? notes;
  final List<ExerciseDto>? exercises;
  final String? status;
  final bool visibleToFriends;

  CreateScheduledDto({
    required this.date,
    this.time,
    required this.planId,
    this.planName,
    this.notes,
    this.exercises,
    this.status,
    required this.visibleToFriends,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'planId': planId,
      'planName': planName,
      'notes': notes,
      'exercises': exercises?.map((e) => e.toJson()).toList(),
      'status': status,
      'visibleToFriends': visibleToFriends,
    };
  }
}

class ScheduledDto {
  final String id;
  final DateTime date;
  final String? time;
  final String planId;
  final String? planName;
  final String? notes;
  final List<ExerciseDto>? exercises;
  final String? status;
  final bool visibleToFriends;

  ScheduledDto({
    required this.id,
    required this.date,
    this.time,
    required this.planId,
    this.planName,
    this.notes,
    this.exercises,
    this.status,
    required this.visibleToFriends,
  });

  factory ScheduledDto.fromJson(Map<String, dynamic> json) {
    return ScheduledDto(
      id: json['id'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      planId: json['planId'],
      planName: json['planName'],
      notes: json['notes'],
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => ExerciseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'],
      visibleToFriends: json['visibleToFriends'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().substring(0, 10), // Date only
      'time': time,
      'planId': planId,
      'planName': planName,
      'notes': notes,
      'exercises': exercises?.map((e) => e.toJson()).toList(),
      'status': status,
      'visibleToFriends': visibleToFriends,
    };
  }
}

// Sessions
class StartSessionRequest {
  final String scheduledId;

  StartSessionRequest({required this.scheduledId});

  Map<String, dynamic> toJson() {
    return {
      'scheduledId': scheduledId,
    };
  }
}

class AddSessionSetRequest {
  final int? setNumber;
  final int repsPlanned;
  final double weightPlanned;

  AddSessionSetRequest({
    this.setNumber,
    required this.repsPlanned,
    required this.weightPlanned,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'repsPlanned': repsPlanned,
      'weightPlanned': weightPlanned,
    };
  }
}

class AddSessionExerciseRequest {
  final int? order;
  final String name;
  final int? restSecPlanned;
  final List<AddSessionSetRequest> sets;

  AddSessionExerciseRequest({
    this.order,
    required this.name,
    this.restSecPlanned,
    required this.sets,
  });

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'name': name,
      'restSecPlanned': restSecPlanned,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }
}

class PatchSetRequest {
  final int? repsDone;
  final double? weightDone;
  final double? rpe;
  final bool? isFailure;

  PatchSetRequest({
    this.repsDone,
    this.weightDone,
    this.rpe,
    this.isFailure,
  });

  Map<String, dynamic> toJson() {
    return {
      'repsDone': repsDone,
      'weightDone': weightDone,
      'rpe': rpe,
      'isFailure': isFailure,
    };
  }
}

class CompleteSessionRequest {
  final String? sessionNotes;
  final DateTime? completedAtUtc;

  CompleteSessionRequest({
    this.sessionNotes,
    this.completedAtUtc,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionNotes': sessionNotes,
      'completedAtUtc': completedAtUtc?.toIso8601String(),
    };
  }
}

class AbortSessionRequest {
  final String? reason;

  AbortSessionRequest({this.reason});

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
    };
  }
}

class SessionSetDto {
  final String id;
  final int setNumber;
  final int repsPlanned;
  final double weightPlanned;
  final int? repsDone;
  final double? weightDone;
  final double? rpe;
  final bool? isFailure;

  SessionSetDto({
    required this.id,
    required this.setNumber,
    required this.repsPlanned,
    required this.weightPlanned,
    this.repsDone,
    this.weightDone,
    this.rpe,
    this.isFailure,
  });

  factory SessionSetDto.fromJson(Map<String, dynamic> json) {
    return SessionSetDto(
      id: json['id'],
      setNumber: json['setNumber'] ?? 0,
      repsPlanned: json['repsPlanned'] ?? 0,
      weightPlanned: json['weightPlanned']?.toDouble() ?? 0.0,
      repsDone: json['repsDone'],
      weightDone: json['weightDone']?.toDouble(),
      rpe: json['rpe']?.toDouble(),
      isFailure: json['isFailure'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setNumber': setNumber,
      'repsPlanned': repsPlanned,
      'weightPlanned': weightPlanned,
      'repsDone': repsDone,
      'weightDone': weightDone,
      'rpe': rpe,
      'isFailure': isFailure,
    };
  }
}

class SessionExerciseDto {
  final String id;
  final int order;
  final String? name;
  final int restSecPlanned;
  final int? restSecActual;
  final List<SessionSetDto>? sets;

  SessionExerciseDto({
    required this.id,
    required this.order,
    this.name,
    required this.restSecPlanned,
    this.restSecActual,
    this.sets,
  });

  factory SessionExerciseDto.fromJson(Map<String, dynamic> json) {
    return SessionExerciseDto(
      id: json['id'],
      order: json['order'] ?? 0,
      name: json['name'],
      restSecPlanned: json['restSecPlanned'] ?? 0,
      restSecActual: json['restSecActual'],
      sets: (json['sets'] as List<dynamic>?)
          ?.map((e) => SessionSetDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'name': name,
      'restSecPlanned': restSecPlanned,
      'restSecActual': restSecActual,
      'sets': sets?.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutSessionDto {
  final String id;
  final String scheduledId;
  final DateTime startedAtUtc;
  final DateTime? completedAtUtc;
  final int? durationSec;
  final String? status;
  final String? sessionNotes;
  final List<SessionExerciseDto>? exercises;

  WorkoutSessionDto({
    required this.id,
    required this.scheduledId,
    required this.startedAtUtc,
    this.completedAtUtc,
    this.durationSec,
    this.status,
    this.sessionNotes,
    this.exercises,
  });

  factory WorkoutSessionDto.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionDto(
      id: json['id'],
      scheduledId: json['scheduledId'],
      startedAtUtc: DateTime.parse(json['startedAtUtc']),
      completedAtUtc: json['completedAtUtc'] != null ? DateTime.parse(json['completedAtUtc']) : null,
      durationSec: json['durationSec'],
      status: json['status'],
      sessionNotes: json['sessionNotes'],
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => SessionExerciseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduledId': scheduledId,
      'startedAtUtc': startedAtUtc.toIso8601String(),
      'completedAtUtc': completedAtUtc?.toIso8601String(),
      'durationSec': durationSec,
      'status': status,
      'sessionNotes': sessionNotes,
      'exercises': exercises?.map((e) => e.toJson()).toList(),
    };
  }
}

// User Profile
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

class UpdateProfileRequest {
  final String userName;
  final String? fullName;
  final String? email;

  UpdateProfileRequest({
    required this.userName,
    this.fullName,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'fullName': fullName,
      'email': email,
    };
  }
}

class UserProfileDto {
  final String id;
  final String? userName;
  final String? fullName;
  final String? email;
  final List<String>? roles;

  UserProfileDto({
    required this.id,
    this.userName,
    this.fullName,
    this.email,
    this.roles,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'],
      userName: json['userName'],
      fullName: json['fullName'],
      email: json['email'],
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'fullName': fullName,
      'email': email,
      'roles': roles,
    };
  }
}

// Users (Admin specific)
class CreateUserDto {
  final String fullName;
  final String email;
  final String userName;

  CreateUserDto({
    required this.fullName,
    required this.email,
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'userName': userName,
    };
  }
}

class UpdateUserDto {
  final String? fullName;
  final String? email;
  final String? userName;

  UpdateUserDto({
    this.fullName,
    this.email,
    this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'userName': userName,
    };
  }
}

class ResetPasswordDto {
  final String newPassword;

  ResetPasswordDto({required this.newPassword});

  Map<String, dynamic> toJson() {
    return {
      'newPassword': newPassword,
    };
  }
}

class UserDto {
  final String id;
  final String? fullName;
  final String? email;
  final String? userName;

  UserDto({
    required this.id,
    this.fullName,
    this.email,
    this.userName,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'userName': userName,
    };
  }
}

