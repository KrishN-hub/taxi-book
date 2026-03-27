import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/ride_request_controller.dart';

class RideRequestPage extends StatelessWidget {
  RideRequestPage({super.key});

  final RideRequestController controller = Get.put(RideRequestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Request')),
      body: Obx(
        () {
          final ride = controller.passengerController.currentRide.value;
          if (ride == null) {
            return const Center(child: Text('No active ride found.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ride ID: ${ride.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Status: ${ride.status}'),
                Text('Pickup: ${ride.pickupAddress}'),
                Text('Drop: ${ride.dropAddress}'),
                const SizedBox(height: 20),
                const Text(
                  'Payment Sandbox',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isProcessingPayment.value
                        ? null
                        : () => controller.payForRide(provider: 'stripe'),
                    child: const Text('Pay with Stripe (Sandbox)'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isProcessingPayment.value
                        ? null
                        : () => controller.payForRide(provider: 'razorpay'),
                    child: const Text('Pay with Razorpay (Sandbox)'),
                  ),
                ),
                if (controller.isProcessingPayment.value) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
