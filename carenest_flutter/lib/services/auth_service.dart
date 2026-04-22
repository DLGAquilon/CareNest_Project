import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;

  /// Called once on app start — restores session from secure storage
  Future<void> init() async {
    final token = await ApiService.loadToken();
    if (token == null) {
      _isLoggedIn = false;
      notifyListeners();
      return;
    }
    try {
      final res = await ApiService.get('/me');
      _user      = res.data;
      _isLoggedIn = true;
    } catch (_) {
      await ApiService.clearToken();
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  /// Login — returns null on success, error string on failure
  Future<String?> login(String username, String password) async {
    try {
      final res = await ApiService.post('/login', {
        'username': username,
        'password': password,
      });
      await ApiService.setToken(res.data['token'] as String);
      _user       = res.data['user'] as Map<String, dynamic>;
      _isLoggedIn = true;
      notifyListeners();
      return null;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']
          ?? e.response?.data?['errors']?.values?.first?.first
          ?? 'Login failed. Check your credentials.';
      return msg.toString();
    }
  }

  /// Register (Admin or Caregiver path — role sent to backend)
  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role, // 'Administrator' or 'Caregiver'
    String? firstName,
    String? lastName,
    String? contactNumber,
  }) async {
    try {
      final body = <String, dynamic>{
        'username':              username,
        'email':                 email,
        'password':              password,
        'password_confirmation': passwordConfirmation,
        'role':                  role,
      };
      if (role == 'Caregiver') {
        body['first_name']      = firstName ?? '';
        body['last_name']       = lastName  ?? '';
        body['contact_number']  = contactNumber ?? '';
      }
      final res = await ApiService.post('/register', body);
      await ApiService.setToken(res.data['token'] as String);
      _user       = res.data['user'] as Map<String, dynamic>;
      _isLoggedIn = true;
      notifyListeners();
      return null;
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'] as Map?;
      if (errors != null && errors.isNotEmpty) {
        return errors.values.first.first.toString();
      }
      return e.response?.data?['message']?.toString() ?? 'Registration failed.';
    }
  }

  Future<void> logout() async {
    try { await ApiService.post('/logout', {}); } catch (_) {}
    await ApiService.clearToken();
    _isLoggedIn = false;
    _user       = null;
    notifyListeners();
  }
}
