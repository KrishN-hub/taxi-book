import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/ride_history_controller.dart';

class RideHistoryPage extends StatelessWidget {
  RideHistoryPage({super.key});

  final RideHistoryController controller = Get.put(RideHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride History')),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.rides.isEmpty) {
            return const Center(child: Text('No rides yet.'));
          }
          return ListView.separated(
            itemCount: controller.rides.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final ride = controller.rides[index];
              return ListTile(
                title: Text('${ride.pickupAddress} -> ${ride.dropAddress}'),
                subtitle: Text('Status: ${ride.status}'),
                trailing: Text(ride.fareAmount?.toStringAsFixed(2) ?? '-'),
              );
            },
          );
        },
      ),
    );
  }
}
