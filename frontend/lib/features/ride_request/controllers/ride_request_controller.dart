import 'package:get/get.dart';

import '../../../data/services/payment_service.dart';
import '../../../data/services/session_service.dart';
import '../../passenger_home/controllers/passenger_home_controller.dart';

class RideRequestController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  final SessionService _session = SessionService.instance;
  final PassengerHomeController passengerController =
      Get.find<PassengerHomeController>();

  final isProcessingPayment = false.obs;

  Future<void> payForRide({required String provider}) async {
    final ride = passengerController.currentRide.value;
    final token = _session.backendToken;
    if (ride == null || token == null) {
      Get.snackbar('Missing ride', 'Ride or session is missing.');
      return;
    }

    try {
      isProcessingPayment.value = true;
      final createRes = await _paymentService.createPayment(
        token: token,
        rideId: ride.id,
        provider: provider,
      );
      final payment = createRes['payment'] as Map<String, dynamic>;
      final paymentId = payment['_id'] as String;

      // Sandbox demo: immediate simulated success confirmation.
      await _paymentService.confirmPayment(
        token: token,
        paymentId: paymentId,
        status: 'paid',
      );
      Get.snackbar('Payment success', 'Sandbox payment marked as paid.');
    } catch (error) {
      Get.snackbar('Payment failed', error.toString());
    } finally {
      isProcessingPayment.value = false;
    }
  }
}
