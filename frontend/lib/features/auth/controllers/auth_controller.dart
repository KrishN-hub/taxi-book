import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/backend_auth_service.dart';
import '../../../data/services/session_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService.instance;
  final BackendAuthService _backendAuthService = BackendAuthService();
  final SessionService _sessionService = SessionService.instance;

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isSignUpPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final selectedRole = 'passenger'.obs;

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    signupConfirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Missing fields', 'Email and password are required.');
      return;
    }

    try {
      isLoading.value = true;
      final credential = await _authService.signIn(email: email, password: password);
      final user = credential.user;
      if (user == null || user.email == null) {
        throw Exception('User data is missing from Firebase login.');
      }

      final backendToken = await _backendAuthService.exchangeFirebaseForBackendToken(
        firebaseUid: user.uid,
        email: user.email!,
        name: user.displayName ?? user.email!.split('@').first,
        role: selectedRole.value,
      );
      _sessionService.backendToken = backendToken;
      _sessionService.selectedRole = selectedRole.value;

      if (selectedRole.value == 'driver') {
        Get.offAllNamed(AppRoutes.driverHome);
      } else {
        Get.offAllNamed(AppRoutes.passengerHome);
      }
    } catch (error) {
      Get.snackbar('Login failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    final email = signupEmailController.text.trim();
    final password = signupPasswordController.text.trim();
    final confirmPassword = signupConfirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Missing fields', 'Please fill in all signup fields.');
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Password mismatch', 'Passwords do not match.');
      return;
    }

    try {
      isLoading.value = true;
      final credential = await _authService.signUp(email: email, password: password);
      final user = credential.user;
      if (user == null || user.email == null) {
        throw Exception('User data is missing from Firebase signup.');
      }

      final backendToken = await _backendAuthService.exchangeFirebaseForBackendToken(
        firebaseUid: user.uid,
        email: user.email!,
        name: user.displayName ?? user.email!.split('@').first,
        role: selectedRole.value,
      );
      _sessionService.backendToken = backendToken;
      _sessionService.selectedRole = selectedRole.value;

      if (selectedRole.value == 'driver') {
        Get.offAllNamed(AppRoutes.driverHome);
      } else {
        Get.offAllNamed(AppRoutes.passengerHome);
      }
    } catch (error) {
      Get.snackbar('Signup failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
