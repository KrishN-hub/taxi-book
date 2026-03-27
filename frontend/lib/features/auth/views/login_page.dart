import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Login to continue booking your rides.'),
              const SizedBox(height: 24),
              CustomTextField(
                controller: controller.loginEmailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                hint: 'name@example.com',
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomTextField(
                  controller: controller.loginPasswordController,
                  label: 'Password',
                  obscureText: controller.isPasswordHidden.value,
                  hint: 'Enter your password',
                  suffixIcon: IconButton(
                    onPressed: () => controller.isPasswordHidden.toggle(),
                    icon: Icon(
                      controller.isPasswordHidden.value
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
                  decoration: const InputDecoration(labelText: 'Login as'),
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
                  label: 'Login',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.login,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.signup),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
