import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/ride_model.dart';
import '../../../data/services/ride_service.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/socket_service.dart';

class PassengerHomeController extends GetxController {
  final RideService _rideService = RideService();
  final SessionService _session = SessionService.instance;
  final SocketService _socketService = SocketService.instance;

  final pickupAddress = 'Current location'.obs;
  final dropAddress = ''.obs;
  final isRequestingRide = false.obs;
  final currentRide = Rxn<RideModel>();
  final driverLivePosition = Rxn<LatLng>();

  // Demo coordinates (replace with geolocator in next step).
  final pickup = const LatLng(28.6139, 77.2090).obs; // New Delhi
  final drop = const LatLng(28.5355, 77.3910).obs; // Noida

  @override
  void onInit() {
    super.onInit();
    _setupSocket();
  }

  void _setupSocket() {
    _socketService.connect();
    final socket = _socketService.socket;

    socket.on('ride:accepted', (data) {
      final rideJson = data['ride'] as Map<String, dynamic>;
      currentRide.value = RideModel.fromJson(rideJson);
      socket.emit('ride:join', {'rideId': currentRide.value!.id});
      Get.snackbar('Driver accepted', 'Your ride has been accepted.');
    });

    socket.on('ride:tracking:update', (data) {
      final location = data['location'] as Map<String, dynamic>? ?? {};
      final lat = (location['lat'] as num?)?.toDouble();
      final lng = (location['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        driverLivePosition.value = LatLng(lat, lng);
      }
    });

    socket.on('ride:status:updated', (data) {
      final rideId = data['rideId']?.toString();
      final status = data['status']?.toString();
      final existing = currentRide.value;
      if (existing != null && rideId == existing.id && status != null) {
        currentRide.value = RideModel(
          id: existing.id,
          status: status,
          pickupAddress: existing.pickupAddress,
          dropAddress: existing.dropAddress,
          driverId: existing.driverId,
          fareAmount: existing.fareAmount,
        );
      }
    });
  }

  Future<void> requestRide() async {
    if (_session.backendToken == null) {
      Get.snackbar('Session expired', 'Please login again.');
      return;
    }
    try {
      isRequestingRide.value = true;
      final ride = await _rideService.requestRide(
        token: _session.backendToken!,
        pickupAddress: pickupAddress.value,
        pickupLng: pickup.value.longitude,
        pickupLat: pickup.value.latitude,
        dropAddress: dropAddress.value.isEmpty ? 'Selected destination' : dropAddress.value,
        dropLng: drop.value.longitude,
        dropLat: drop.value.latitude,
      );
      currentRide.value = ride;
      _socketService.socket.emit('ride:join', {'rideId': ride.id});
      Get.toNamed(AppRoutes.rideRequest);
    } catch (error) {
      Get.snackbar('Ride request failed', error.toString());
    } finally {
      isRequestingRide.value = false;
    }
  }
}
