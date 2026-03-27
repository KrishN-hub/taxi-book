import 'dart:async';

import 'package:get/get.dart';

import '../../../data/services/api_client.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/socket_service.dart';

class DriverHomeController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final SessionService _session = SessionService.instance;
  final SocketService _socketService = SocketService.instance;

  final incomingRides = <Map<String, dynamic>>[].obs;
  final activeRideId = RxnString();
  Timer? _trackingTimer;

  @override
  void onInit() {
    super.onInit();
    _setupDriverSocket();
  }

  void _setupDriverSocket() {
    _socketService.connect();
    final socket = _socketService.socket;

    // Demo static driver id binding. In production use driver profile id from backend.
    socket.emit('join:driver', {'driverId': 'demo-driver-id'});

    socket.on('ride:request:new', (data) {
      incomingRides.add(data['ride'] as Map<String, dynamic>);
      Get.snackbar('New ride request', 'Passenger is requesting a ride');
    });
  }

  Future<void> acceptRide(String rideId) async {
    final token = _session.backendToken;
    if (token == null) return;
    try {
      await _apiClient.post('/rides/accept', token: token, body: {'rideId': rideId});
      activeRideId.value = rideId;
      incomingRides.removeWhere((item) => item['_id'] == rideId);
      _startSendingLocation();
      Get.snackbar('Ride accepted', 'Tracking updates started.');
    } catch (error) {
      Get.snackbar('Accept failed', error.toString());
    }
  }

  void _startSendingLocation() {
    _trackingTimer?.cancel();
    double lat = 28.62;
    double lng = 77.21;

    _trackingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (activeRideId.value == null) return;
      lat += 0.0005;
      lng += 0.0005;
      _socketService.socket.emit('driver:location:update', {
        'driverId': 'demo-driver-id',
        'rideId': activeRideId.value,
        'lat': lat,
        'lng': lng,
      });
    });
  }

  @override
  void onClose() {
    _trackingTimer?.cancel();
    super.onClose();
  }
}
