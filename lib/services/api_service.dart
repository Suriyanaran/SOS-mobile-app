import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/sos_model.dart';

class ApiService {
  static const String _keyToken = 'aero_sos_auth_token';
  static const String _keyBaseUrl = 'aero_sos_base_url';

  // In Chrome/Web use 127.0.0.1:8000; In Android Emulator use 10.0.2.2:8000
  static String get defaultBaseUrl => kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';

  String _baseUrl = kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';
  String? _token;

  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  String get baseUrl => _baseUrl;
  String? get token => _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    String? stored = prefs.getString(_keyBaseUrl);
    if (kIsWeb && (stored == null || stored.contains('10.0.2.2'))) {
      stored = 'http://127.0.0.1:8000';
      await prefs.setString(_keyBaseUrl, stored);
    }
    _baseUrl = stored ?? defaultBaseUrl;
    _token = prefs.getString(_keyToken);
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, _baseUrl);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  Map<String, String> _headers() {
    final map = {'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) {
      map['Authorization'] = 'Bearer $_token';
    }
    return map;
  }

  /// FEATURE 1: Phone + OTP Request
  Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    final uri = Uri.parse('$_baseUrl/api/auth/request-otp');
    final response = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({'phone_number': phoneNumber}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['detail'] ?? data['message'] ?? 'Failed to request OTP');
    }
    return data;
  }

  /// FEATURE 1: Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final uri = Uri.parse('$_baseUrl/api/auth/verify-otp');
    final response = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({'phone_number': phoneNumber, 'otp': otp}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['detail'] ?? data['message'] ?? 'Invalid OTP code');
    }

    if (data['token'] != null) {
      await saveToken(data['token']);
    }
    return data;
  }

  /// FEATURE 2: Update Profile
  Future<UserModel> updateProfile(UserModel user) async {
    final uri = Uri.parse('$_baseUrl/api/auth/profile');
    final response = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode(user.toJson()),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['detail'] ?? data['message'] ?? 'Failed to update profile');
    }
    return UserModel.fromJson(data['user']);
  }

  /// Get Current User
  Future<UserModel?> getMe() async {
    if (_token == null) return null;
    final uri = Uri.parse('$_baseUrl/api/auth/me');
    final response = await http.get(uri, headers: _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['user']);
    }
    return null;
  }

  /// FEATURE 5: Submit SOS
  Future<SosModel> createSos({
    required String emergencyType,
    required double latitude,
    required double longitude,
    required double accuracyM,
    required String notes,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/sos');
    final response = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'emergency_type': emergencyType,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy_m': accuracyM,
        'notes': notes,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['detail'] ?? data['message'] ?? 'SOS creation failed');
    }
    return SosModel.fromJson(data);
  }

  /// GET SOS Details
  Future<SosModel> getSos(String sosId) async {
    final uri = Uri.parse('$_baseUrl/api/sos/$sosId');
    final response = await http.get(uri, headers: _headers());

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['detail'] ?? data['message'] ?? 'Failed to get SOS');
    }
    return SosModel.fromJson(data);
  }

  /// Cancel SOS
  Future<SosModel> cancelSos(String sosId) async {
    final uri = Uri.parse('$_baseUrl/api/sos/$sosId/cancel');
    final response = await http.post(uri, headers: _headers());

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['detail'] ?? data['message'] ?? 'Failed to cancel SOS');
    }
    return SosModel.fromJson(data['sos']);
  }
}
