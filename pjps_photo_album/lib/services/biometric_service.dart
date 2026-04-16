import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  final Dio dio = Dio();

  final _tokenKey = 'api_token';

  BiometricService() {
    dio.options.baseUrl = 'http://10.178.161.217:8000/api/';
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Token $token';
        }
        return handler.next(options);
      },
    ));
  }

  // ------------------ Existing Biometric Functions ------------------

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting biometrics: $e');
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics({
    required String reason,
    String? cancelButton,
    String? localizedReason,
  }) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason ?? reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          // biometricOnly was removed
          sensitiveTransaction: true,
        ),
      );
      return isAuthenticated;
    } on PlatformException catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }

  Future<void> saveBiometricCredentials(
      String username, String password) async {
    await _storage.write(key: 'biometric_username', value: username);
    await _storage.write(key: 'biometric_password', value: password);
    await _storage.write(key: 'biometric_enabled', value: 'true');
  }

  Future<Map<String, String>?> getBiometricCredentials() async {
    final username = await _storage.read(key: 'biometric_username');
    final password = await _storage.read(key: 'biometric_password');
    final enabled = await _storage.read(key: 'biometric_enabled');

    if (username != null && password != null && enabled == 'true') {
      return {'username': username, 'password': password};
    }
    return null;
  }

  Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: 'biometric_enabled');
    return enabled == 'true';
  }

  Future<void> disableBiometric() async {
    await _storage.delete(key: 'biometric_username');
    await _storage.delete(key: 'biometric_password');
    await _storage.delete(key: 'biometric_enabled');
    await _storage.delete(key: _tokenKey); // also remove token
  }

  void stopAuthentication() {
    _localAuth.stopAuthentication();
  }

  // ------------------ New Token / Biometric API Functions ------------------

  Future<void> saveApiToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> tryBiometricLogin() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;

    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) return null;

    final didAuthenticate = await _localAuth.authenticate(
      localizedReason: 'Authenticate to login',
      options: const AuthenticationOptions(
        stickyAuth: true,
        sensitiveTransaction: true,
      ),
    );

    if (didAuthenticate) {
      return token;
    }
    return null;
  }

  Future<Response> getAlbums() async {
    return await dio.get('albums/year-levels/');
  }
}
