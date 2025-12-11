import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fitmate/models/friend.dart';
import 'package:fitmate/models/friend_request.dart';
import 'package:fitmate/models/shared_plan.dart';
import 'package:fitmate/models/plan.dart';
import 'package:fitmate/models/scheduled_workout.dart';
import 'package:fitmate/api/models/models.dart';
import 'package:intl/intl.dart';

class ApiClient {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  String? _accessToken;
  String? _refreshToken;

  String? _username;
  String? _email;

  String? get username => _username;
  String? get email => _email;

  void setTokens(String? accessToken, String? refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    if (accessToken != null) {
      _extractUserFromToken(accessToken);
    }
  }

  void _extractUserFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(resp);

      // Extract Email
      if (payloadMap.containsKey('email')) {
        _email = payloadMap['email'];
      } else if (payloadMap.containsKey(
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress')) {
        _email = payloadMap[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];
      }

      // Extract Username
      if (payloadMap.containsKey('unique_name')) {
        _username = payloadMap['unique_name'];
      } else if (payloadMap.containsKey('name')) {
        _username = payloadMap['name'];
      } else if (payloadMap.containsKey(
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name')) {
        _username = payloadMap[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'];
      }

      debugPrint('Extracted user: $_username, email: $_email');
    } catch (e) {
      debugPrint('Error decoding JWT: $e');
    }
  }

  bool get isAuthenticated => _accessToken != null;

  Map<String, String> _createHeaders(
      {bool authorized = true, bool isJson = true}) {
    final Map<String, String> headers = {};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (authorized && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<http.Response> getData(String path,
      {Map<String, dynamic>? queryParams, bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path).replace(
        queryParameters:
            queryParams?.map((key, value) => MapEntry(key, value.toString())));
    return _request(
        () => http
            .get(uri,
                headers: _createHeaders(authorized: authorized, isJson: false))
            .timeout(const Duration(seconds: 10)),
        authorized: authorized);
  }

  Future<http.Response> post(String path,
      {dynamic body, bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path);
    return _request(() {
      if (body != null) {
        debugPrint('POST Request Body: ${json.encode(body)}');
      }
      return http
          .post(uri,
              headers: _createHeaders(authorized: authorized),
              body: json.encode(body))
          .timeout(const Duration(seconds: 10));
    }, authorized: authorized);
  }

  Future<http.Response> put(String path,
      {dynamic body, bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path);
    return _request(() {
      if (body != null) {
        debugPrint('PUT Request Body: ${json.encode(body)}');
      }
      return http
          .put(uri,
              headers: _createHeaders(authorized: authorized),
              body: json.encode(body))
          .timeout(const Duration(seconds: 10));
    }, authorized: authorized);
  }

  Future<http.Response> patch(String path,
      {dynamic body, bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path);
    return _request(
        () => http
            .patch(uri,
                headers: _createHeaders(authorized: authorized),
                body: json.encode(body))
            .timeout(const Duration(seconds: 10)),
        authorized: authorized);
  }

  Future<http.Response> delete(String path, {bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path);
    return _request(
        () => http
            .delete(uri, headers: _createHeaders(authorized: authorized))
            .timeout(const Duration(seconds: 10)),
        authorized: authorized);
  }

  Future<http.Response> _request(Future<http.Response> Function() request,
      {required bool authorized}) async {
    try {
      http.Response response = await request();
      if (response.statusCode == 401 && authorized) {
        // Token might be expired, try to refresh
        if (await _refreshAccessToken()) {
          // Retry the original request
          return await request();
        }
      }
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(
          ProblemDetails(detail: "Connection timed out", status: 408), 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
          ProblemDetails(detail: "Network error: $e", status: 503), 503);
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'refreshToken': _refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setTokens(data['accessToken'], data['refreshToken']);
        return true;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
    }
    return false;
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 400) {
      throw ApiException(ProblemDetails.fromJson(json.decode(response.body)),
          response.statusCode);
    } else if (response.statusCode == 401) {
      throw ApiException(ProblemDetails(detail: "Unauthorized", status: 401),
          response.statusCode);
    } else if (response.statusCode == 403) {
      throw ApiException(ProblemDetails(detail: "Forbidden", status: 403),
          response.statusCode);
    } else if (response.statusCode == 404) {
      throw ApiException(ProblemDetails(detail: "Not Found", status: 404),
          response.statusCode);
    } else if (response.statusCode >= 500) {
      throw ApiException(
          ProblemDetails(detail: "Server Error", status: response.statusCode),
          response.statusCode);
    } else {
      throw ApiException(
          ProblemDetails(
              detail: "An unexpected error occurred",
              status: response.statusCode),
          response.statusCode);
    }
  }

  // Auth
  Future<void> login(String username, String password) async {
    final response = await post('/api/auth/login',
        body: {'userNameOrEmail': username, 'password': password},
        authorized: false);
    final data = json.decode(response.body);
    setTokens(data['accessToken'], data['refreshToken']);
  }

  Future<void> register(
      String email, String username, String password, String fullName) async {
    final response = await post('/api/auth/register',
        body: {
          'email': email,
          'username': username,
          'password': password,
          'fullName': fullName
        },
        authorized: false);
    final data = json.decode(response.body);
    setTokens(data['accessToken'], data['refreshToken']);
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _username = null;
    _email = null;
  }

  // Plans
  Future<List<Plan>> getPlans() async {
    try {
      final response = await getData('/api/plans');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Plan.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<Plan> getPlan(String planId) async {
    try {
      final response = await getData('/api/plans/$planId');
      return Plan.fromJson(json.decode(response.body));
    } catch (e) {
      debugPrint('CRITICAL: Failed to get plan $planId: $e');
      rethrow;
    }
  }

  Future<Plan> createPlan(Plan plan) async {
    final response = await post('/api/plans', body: plan.toJson());
    return Plan.fromJson(json.decode(response.body));
  }

  Future<void> deletePlan(String planId) async {
    await delete('/api/plans/$planId');
  }

  // Scheduled Workouts
  Future<List<ScheduledWorkout>> getScheduledWorkouts() async {
    try {
      final response = await getData('/api/scheduled');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ScheduledWorkout.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<ScheduledWorkout> getScheduledWorkout(String id) async {
    final response = await getData('/api/scheduled/$id');
    return ScheduledWorkout.fromJson(json.decode(response.body));
  }

  Future<ScheduledWorkout> scheduleWorkout(ScheduledWorkout workout) async {
    final body = {
      'date': DateFormat('yyyy-MM-dd').format(workout.date),
      'time': workout.time,
      'planId': workout.planId,
      'planName': workout.planName,
      'status': workout.status.name,
      'exercises': workout.exercises.map((e) => e.toJson()).toList(),
      'visibleToFriends': true,
    };

    final response = await post('/api/scheduled', body: body);
    return ScheduledWorkout.fromJson(json.decode(response.body));
  }

  Future<void> completeWorkout(ScheduledWorkout workout) async {
    final body = {
      'date': DateFormat('yyyy-MM-dd').format(workout.date),
      'time': workout.time,
      'planId': workout.planId,
      'planName': workout.planName,
      'status': 'completed',
      'exercises': workout.exercises.map((e) => e.toJson()).toList(),
      'visibleToFriends': true,
    };

    await put('/api/scheduled/${workout.id}', body: body);
  }

  Future<void> deleteScheduledWorkout(String workoutId) async {
    await delete('/api/scheduled/$workoutId');
  }

  // Friends
  Future<List<Friend>> getFriends() async {
    try {
      final response = await getData('/api/friends');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Friend.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<List<FriendRequest>> getIncomingRequests() async {
    try {
      final response = await getData('/api/friends/requests/incoming');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FriendRequest.fromJson(json)).toList();
    } on ApiException catch (e) {
      // 404 for empty list or endpoint weirdness
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<List<FriendRequest>> getOutgoingRequests() async {
    try {
      final response = await getData('/api/friends/requests/outgoing');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FriendRequest.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<void> sendFriendRequest(String username) async {
    await post('/api/friends/$username');
  }

  Future<void> respondToFriendRequest(String requestId, bool accept) async {
    // Assuming body { "accept": true/false }
    await post('/api/friends/requests/$requestId/respond',
        body: {'accept': accept});
  }

  Future<void> removeFriend(String friendUserId) async {
    await delete('/api/friends/$friendUserId');
  }

  // Plan Sharing
  Future<void> sharePlan(String planId, String targetUserId) async {
    await post('/api/plans/$planId/share-to/$targetUserId');
  }

  Future<List<SharedPlan>> getSharedPlansWithMe() async {
    try {
      final response =
          await getData('/api/plans/shared/history?scope=received');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SharedPlan.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<List<SharedPlan>> getSharedPlansByMe() async {
    try {
      final response = await getData('/api/plans/shared/history?scope=sent');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SharedPlan.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<List<SharedPlan>> getPendingSharedPlans() async {
    try {
      final response = await getData('/api/plans/shared/pending');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SharedPlan.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<List<SharedPlan>> getSentPendingSharedPlans() async {
    try {
      final response = await getData('/api/plans/shared/sent/pending');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SharedPlan.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<void> respondToSharedPlan(String sharedPlanId, bool accept) async {
    await post('/api/plans/shared/$sharedPlanId/respond',
        body: {'accept': accept});
  }

  Future<void> removeSharedPlan(String sharedPlanId) async {
    await delete('/api/plans/shared/$sharedPlanId');
  }

  // Body Measurements
  Future<List<BodyMeasurementDto>> getBodyMeasurements() async {
    try {
      final response = await getData('/api/body-metrics');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BodyMeasurementDto.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<BodyMetricsStatsDto?> getBodyMetricsStats() async {
    try {
      final response = await getData('/api/body-metrics/stats');
      return BodyMetricsStatsDto.fromJson(json.decode(response.body));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<BodyMetricsProgressDto>> getBodyMetricsProgress() async {
    try {
      final response = await getData('/api/body-metrics/progress');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BodyMetricsProgressDto.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<BodyMeasurementDto> saveBodyMeasurement(
      CreateBodyMeasurementDto measurement) async {
    final response =
        await post('/api/body-metrics', body: measurement.toJson());
    return BodyMeasurementDto.fromJson(json.decode(response.body));
  }

  Future<void> deleteBodyMeasurement(String id) async {
    await delete('/api/body-metrics/$id');
  }
}

class ApiException implements Exception {
  final ProblemDetails problem;
  final int statusCode;

  ApiException(this.problem, this.statusCode);

  @override
  String toString() {
    if (problem.errors != null && problem.errors!.isNotEmpty) {
      final errorsStr = problem.errors!.entries
          .map((e) => '${e.key}: ${e.value.join(", ")}')
          .join('; ');
      return 'ApiException: Status code $statusCode, Detail: ${problem.detail}, Errors: $errorsStr';
    }
    return 'ApiException: Status code $statusCode, Detail: ${problem.detail}';
  }
}

class ProblemDetails {
  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String? instance;
  final Map<String, dynamic>? errors;

  ProblemDetails(
      {this.type,
      this.title,
      this.status,
      this.detail,
      this.instance,
      this.errors});

  factory ProblemDetails.fromJson(Map<String, dynamic> json) {
    return ProblemDetails(
      type: json['type'],
      title: json['title'],
      status: json['status'],
      detail: json['detail'],
      instance: json['instance'],
      errors: json['errors'],
    );
  }
}
