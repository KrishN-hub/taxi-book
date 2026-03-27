import 'package:get/get.dart';

import '../../../data/models/ride_model.dart';
import '../../../data/services/ride_service.dart';
import '../../../data/services/session_service.dart';

class RideHistoryController extends GetxController {
  final RideService _rideService = RideService();
  final SessionService _session = SessionService.instance;

  final rides = <RideModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRideHistory();
  }

  Future<void> loadRideHistory() async {
    final token = _session.backendToken;
    if (token == null) return;

    try {
      isLoading.value = true;
      final result = await _rideService.getRideHistory(token: token);
      rides.assignAll(result);
    } catch (error) {
      Get.snackbar('Failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
