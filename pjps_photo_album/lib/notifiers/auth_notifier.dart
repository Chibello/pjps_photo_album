import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../core/providers/service_providers.dart';

/// State class for authentication
class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool biometricAvailable;
  final bool biometricEnabled;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.biometricAvailable = false,
    this.biometricEnabled = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? biometricAvailable,
    bool? biometricEnabled,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}

/// StateNotifier for authentication
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final BiometricService _biometricService;

  AuthNotifier(this._authService, this._biometricService) : super(AuthState()) {
    _checkBiometricStatus();
  }

  /// Public getter to safely expose biometric availability
  bool get biometricAvailable => state.biometricAvailable;

  /// Check if biometrics are available/enabled
  Future<void> _checkBiometricStatus() async {
    try {
      final status = await _authService.getBiometricStatus();
      state = state.copyWith(
        biometricAvailable: status['available'] ?? false,
        biometricEnabled: status['enabled'] ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        biometricAvailable: false,
        biometricEnabled: false,
      );
    }
  }

  /// Normal login
  Future<bool> login(String registrationNumber, String password,
      {bool enableBiometric = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(
        registrationNumber,
        password,
        enableBiometric: enableBiometric,
      );
      state = state.copyWith(
        isLoading: false,
        user: user,
        biometricEnabled: enableBiometric,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Biometric login
  Future<bool> loginWithBiometrics() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.loginWithBiometrics();
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// ✅ NEW METHOD: Check if saved credentials exist
  Future<bool> hasSavedCredentials() async {
    try {
      final token = await _authService.getCurrentUser();
      return token != null;
    } catch (_) {
      return false;
    }
  }

  /// Toggle biometric login setting
  Future<void> toggleBiometric(bool enabled) async {
    if (!enabled) {
      await _biometricService.disableBiometric();
    }
    state = state.copyWith(biometricEnabled: enabled);
  }

  /// Check current authentication status
  Future<bool> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuthenticated = await _authService.checkAuthStatus();
      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(isLoading: false, user: user);
      } else {
        state = state.copyWith(isLoading: false, user: null);
      }
      return isAuthenticated;
    } catch (e) {
      state = state.copyWith(isLoading: false, user: null);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
      final status = await _authService.getBiometricStatus();
      state = AuthState(
        biometricAvailable: status['available'] ?? false,
        biometricEnabled: status['enabled'] ?? false,
      );
    } catch (e) {
      state = AuthState();
    }
  }

  /// Clear any errors
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    final authService = ref.read(authServiceProvider);
    final biometricService = ref.read(biometricServiceProvider);
    return AuthNotifier(authService, biometricService);
  },
);
