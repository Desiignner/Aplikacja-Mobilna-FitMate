import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/models.dart'; // Importuj swoje modele

class ApiClient {
  static const String _baseUrl = 'http://localhost:8080'; // Zaktualizuj, jeśli API będzie gdzie indziej
  String? _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> _getHeaders({bool authorized = true, bool isJson = true}) {
    final Map<String, String> headers = {};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (authorized && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<http.Response> get(String path, {Map<String, dynamic>? queryParams, bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path).replace(queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString())));
    final response = await http.get(uri, headers: _getHeaders(authorized: authorized, isJson: false));
    return _handleResponse(response);
  }

  Future<http.Response> post(String path, {dynamic body, bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path);
    final response = await http.post(uri, headers: _getHeaders(authorized: authorized), body: json.encode(body));
    return _handleResponse(response);
  }

  Future<http.Response> put(String path, {dynamic body, bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path);
    final response = await http.put(uri, headers: _getHeaders(authorized: authorized), body: json.encode(body));
    return _handleResponse(response);
  }

  Future<http.Response> patch(String path, {dynamic body, bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path);
    final response = await http.patch(uri, headers: _getHeaders(authorized: authorized), body: json.encode(body));
    return _handleResponse(response);
  }

  Future<http.Response> delete(String path, {bool authorized = true}) async {
    final uri = Uri.parse(_baseUrl + path);
    final response = await http.delete(uri, headers: _getHeaders(authorized: authorized));
    return _handleResponse(response);
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 400) {
      throw ApiException(ProblemDetails.fromJson(json.decode(response.body)), response.statusCode);
    } else if (response.statusCode == 401) {
      throw ApiException(ProblemDetails(detail: "Unauthorized", status: 401), response.statusCode);
    } else if (response.statusCode == 403) {
      throw ApiException(ProblemDetails(detail: "Forbidden", status: 403), response.statusCode);
    } else if (response.statusCode == 404) {
      throw ApiException(ProblemDetails(detail: "Not Found", status: 404), response.statusCode);
    } else if (response.statusCode >= 500) {
      throw ApiException(ProblemDetails(detail: "Server Error", status: response.statusCode), response.statusCode);
    } else {
      throw ApiException(ProblemDetails(detail: "An unexpected error occurred", status: response.statusCode), response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final ProblemDetails details;
  final int statusCode;

  ApiException(this.details, this.statusCode);

  @override
  String toString() {
    return 'ApiException: Status code $statusCode, Detail: ${details.detail ?? "Unknown error"}';
  }
}
