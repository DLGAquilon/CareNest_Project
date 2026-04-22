import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  /// kIsWeb = true when running as Flutter Web (localhost:XXXXX in browser)
  /// Android emulator needs 10.0.2.2 to reach the host machine's localhost
  /// Real phone on WiFi needs your PC's local IP e.g. 192.168.1.x
  /// 

  static const String _pcLocalIp = '192.168.1.58';
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api'; // Flutter web in browser
    }
    return 'http://$_pcLocalIp:8000/api';   // Android emulator
    // For a real phone, replace with: 'http://192.168.1.x:8000/api'
  }

  static const _storage = FlutterSecureStorage();

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,           // now reads the getter above
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept':       'application/json',
      'Content-Type': 'application/json',
    },
  ));

  static Future<void> setToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static Future<String?> loadToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return token;
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
    _dio.options.headers.remove('Authorization');
  }

  static Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  static Future<Response> post(String path, Map<String, dynamic> data) =>
      _dio.post(path, data: data);

  static Future<Response> put(String path, Map<String, dynamic> data) =>
      _dio.put(path, data: data);

  static Future<Response> delete(String path) => _dio.delete(path);
}
