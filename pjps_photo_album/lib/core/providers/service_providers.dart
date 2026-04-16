import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';

// Provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Provider for BiometricService
final biometricServiceProvider =
    Provider<BiometricService>((ref) => BiometricService());

// Provider for AuthService
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.read(apiServiceProvider),
    ref.read(biometricServiceProvider),
  ),
);
