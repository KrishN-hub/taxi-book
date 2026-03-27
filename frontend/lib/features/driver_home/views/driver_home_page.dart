import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/driver_home_controller.dart';

class DriverHomePage extends StatelessWidget {
  DriverHomePage({super.key});

  final DriverHomeController controller = Get.put(DriverHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService.instance.signOut();
              Get.offAllNamed(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.incomingRides.isEmpty) {
            return const Center(child: Text('No ride requests yet.'));
          }
          return ListView.builder(
            itemCount: controller.incomingRides.length,
            itemBuilder: (_, index) {
              final ride = controller.incomingRides[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ride ID: ${ride['_id']}'),
                      Text('Pickup: ${ride['pickup']?['address'] ?? '-'}'),
                      Text('Drop: ${ride['drop']?['address'] ?? '-'}'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => controller.acceptRide(ride['_id'] as String),
                        child: const Text('Accept Ride'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
