import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fitmate/models/plan.dart';
import 'package:fitmate/models/scheduled_workout.dart';
import 'package:intl/intl.dart';

class ApiClient {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  String? _accessToken;
  String? _refreshToken;

  void setTokens(String? accessToken, String? refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  bool get isAuthenticated => _accessToken != null;

  Map<String, String> _getHeaders(
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

  Future<http.Response> get(String path,
      {Map<String, dynamic>? queryParams, bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path).replace(
        queryParameters:
            queryParams?.map((key, value) => MapEntry(key, value.toString())));
    return _request(
        () => http
            .get(uri,
                headers: _getHeaders(authorized: authorized, isJson: false))
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
              headers: _getHeaders(authorized: authorized),
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
              headers: _getHeaders(authorized: authorized),
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
                headers: _getHeaders(authorized: authorized),
                body: json.encode(body))
            .timeout(const Duration(seconds: 10)),
        authorized: authorized);
  }

  Future<http.Response> delete(String path, {bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path);
    return _request(
        () => http
            .delete(uri, headers: _getHeaders(authorized: authorized))
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

  String? _username;
  String? _email;

  String? get username => _username;
  String? get email => _email;

  // Auth
  Future<void> login(String username, String password) async {
    final response = await post('/api/auth/login',
        body: {'userNameOrEmail': username, 'password': password},
        authorized: false);
    final data = json.decode(response.body);
    setTokens(data['accessToken'], data['refreshToken']);
    _username = username; // Best guess for now
    if (username.contains('@')) {
      _email = username;
    }
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
    _username = username;
    _email = email;
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
      final response = await get('/api/plans');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Plan.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
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
      final response = await get('/api/scheduled');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ScheduledWorkout.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<ScheduledWorkout> getScheduledWorkout(String id) async {
    final response = await get('/api/scheduled/$id');
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
