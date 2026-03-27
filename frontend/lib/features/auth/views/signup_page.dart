import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Signup with Firebase Auth to start using Snail Taxi.'),
              const SizedBox(height: 24),
              CustomTextField(
                controller: controller.signupEmailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                hint: 'name@example.com',
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomTextField(
                  controller: controller.signupPasswordController,
                  label: 'Password',
                  obscureText: controller.isSignUpPasswordHidden.value,
                  hint: 'At least 6 characters',
                  suffixIcon: IconButton(
                    onPressed: () => controller.isSignUpPasswordHidden.toggle(),
                    icon: Icon(
                      controller.isSignUpPasswordHidden.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomTextField(
                  controller: controller.signupConfirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: controller.isConfirmPasswordHidden.value,
                  hint: 'Re-enter password',
                  suffixIcon: IconButton(
                    onPressed: () => controller.isConfirmPasswordHidden.toggle(),
                    icon: Icon(
                      controller.isConfirmPasswordHidden.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedRole.value,
                  decoration: const InputDecoration(labelText: 'Create account as'),
                  items: const [
                    DropdownMenuItem(value: 'passenger', child: Text('Passenger')),
                    DropdownMenuItem(value: 'driver', child: Text('Driver')),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.selectedRole.value = value;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomButton(
                  label: 'Sign Up',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.signup,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
