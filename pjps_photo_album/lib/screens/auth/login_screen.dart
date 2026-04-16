import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regNoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _enableBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    // Already handled in notifier
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authProvider.notifier);

      final success = await authNotifier.login(
        _regNoController.text.trim(),
        _passwordController.text,
        enableBiometric: _enableBiometric,
      );

      if (success && mounted) {
        context.go('/dashboard');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(authProvider).error ?? 'Login failed'),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final authNotifier = ref.read(authProvider.notifier);

    final success = await authNotifier.loginWithBiometrics();

    if (success && mounted) {
      context.go('/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(ref.read(authProvider).error ?? 'Biometric login failed'),
          backgroundColor: AppColors.error,
        ),
      );
      ref.read(authProvider.notifier).clearError();
    }
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return LoadingOverlay(
      isLoading: authState.isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Login with your registration number',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryAsh,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Registration Number Field
                  CustomTextField(
                    controller: _regNoController,
                    label: 'Registration Number',
                    hint: 'Enter your registration number',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter registration number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.secondaryAsh,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),

                  // Biometric Checkbox (only show if available)
                  if (authState.biometricAvailable) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _enableBiometric,
                          onChanged: (value) {
                            setState(() {
                              _enableBiometric = value ?? false;
                            });
                          },
                          activeColor: AppColors.primaryGold,
                          checkColor: Colors.white,
                        ),
                        const Expanded(
                          child: Text(
                            'Enable fingerprint/face ID for faster login',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Login Button
                  CustomButton(
                    text: 'Login',
                    onPressed: _handleLogin,
                  ),

                  // Biometric Login Button (if enabled)
                  if (authState.biometricEnabled) ...[
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Login with Fingerprint',
                      onPressed: _handleBiometricLogin,
                      isOutlined: true,
                      icon: Icons.fingerprint,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Help Text
                  Center(
                    child: Text(
                      'Contact administrator if you forgot your password',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryAsh.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
