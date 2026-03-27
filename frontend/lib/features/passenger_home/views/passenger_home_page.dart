import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/passenger_home_controller.dart';

class PassengerHomePage extends StatelessWidget {
  PassengerHomePage({super.key});

  final PassengerHomeController controller = Get.put(PassengerHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Home'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.rideHistory),
            icon: const Icon(Icons.history),
          ),
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
        () => Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: controller.pickup.value,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.snail.taxi.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: controller.pickup.value,
                        width: 48,
                        height: 48,
                        child: const Icon(Icons.location_on, color: Colors.green, size: 36),
                      ),
                      Marker(
                        point: controller.drop.value,
                        width: 48,
                        height: 48,
                        child: const Icon(Icons.flag, color: Colors.red, size: 34),
                      ),
                      if (controller.driverLivePosition.value != null)
                        Marker(
                          point: controller.driverLivePosition.value ?? const LatLng(0, 0),
                          width: 48,
                          height: 48,
                          child: const Icon(Icons.local_taxi, color: Colors.black87, size: 34),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Drop location address'),
                    onChanged: (value) => controller.dropAddress.value = value,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isRequestingRide.value ? null : controller.requestRide,
                      child: controller.isRequestingRide.value
                          ? const CircularProgressIndicator()
                          : const Text('Request Ride'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
