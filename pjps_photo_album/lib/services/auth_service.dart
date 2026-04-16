import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'api_service.dart';
import 'biometric_service.dart';

class AuthService {
  final ApiService _apiService;
  final BiometricService _biometricService;
  final _storage = const FlutterSecureStorage();

  AuthService(this._apiService, this._biometricService);

  // Regular login
  Future<UserModel> login(String registrationNumber, String password,
      {bool enableBiometric = false}) async {
    try {
      final response = await _apiService.post(
        '/auth/login/',
        data: {
          'registration_number': registrationNumber,
          'password': password,
        },
      );

      final data = response.data;

      // Store access and refresh tokens
      await _storage.write(
          key: AppConstants.accessTokenKey, value: data['access_token']);
      await _storage.write(
          key: AppConstants.refreshTokenKey, value: data['refresh_token']);
      await _storage.write(
        key: AppConstants.userKey,
        value: json.encode(data['user']),
      );

      // Save credentials for biometric login if enabled
      if (enableBiometric) {
        await _biometricService.saveBiometricCredentials(
            registrationNumber, password);
      }

      return UserModel.fromJson(data['user']);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw Exception(e.response?.data['error'] ?? 'Login failed');
      }
      throw Exception('Network error. Please check your connection.');
    }
  }

  // Biometric login
  Future<UserModel?> loginWithBiometrics() async {
    try {
      final authenticated = await _biometricService.authenticateWithBiometrics(
        reason: 'Authenticate to login to PJPS Photo Album',
      );

      if (!authenticated) {
        return null; // safe for first-time users
      }

      final credentials = await _biometricService.getBiometricCredentials();
      if (credentials == null) {
        return null; // no credentials saved
      }

      return await login(credentials['username']!, credentials['password']!);
    } catch (e) {
      print('Biometric login error: $e');
      return null; // prevent crashes
    }
  }

  // Check if biometric is available and enabled
  Future<Map<String, bool>> getBiometricStatus() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricEnabled();
    return {
      'available': available,
      'enabled': enabled,
    };
  }

  // Regular logout
  Future<void> logout() async {
    try {
      final refreshToken =
          await _storage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken != null) {
        await _apiService.post('/auth/logout/', data: {
          'refresh_token': refreshToken,
        });
      }
    } catch (_) {
      // ignore logout errors
    } finally {
      final biometricEnabled = await _biometricService.isBiometricEnabled();
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
      await _storage.delete(key: AppConstants.userKey);

      if (!biometricEnabled) {
        await _biometricService.disableBiometric();
      }
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final userString = await _storage.read(key: AppConstants.userKey);
    if (userString != null) {
      return UserModel.fromJson(json.decode(userString));
    }
    return null;
  }

  // Check auth status safely
  Future<bool> checkAuthStatus() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token == null) return false;

    try {
      await _apiService.get('/auth/users/me/');
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // ✅ Get the saved access token
  Future<String?> getSavedToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  // ✅ Check if there are saved credentials for biometrics
  Future<bool> hasSavedCredentials() async {
    final credentials = await _biometricService.getBiometricCredentials();
    return credentials != null;
  }
}
