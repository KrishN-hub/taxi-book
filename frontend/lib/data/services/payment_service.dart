import 'api_client.dart';

class PaymentService {
  PaymentService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> createPayment({
    required String token,
    required String rideId,
    required String provider,
  }) {
    return _apiClient.post(
      '/payments/create',
      token: token,
      body: {
        'rideId': rideId,
        'provider': provider,
        'currency': 'INR',
      },
    );
  }

  Future<Map<String, dynamic>> confirmPayment({
    required String token,
    required String paymentId,
    required String status,
  }) {
    return _apiClient.post(
      '/payments/confirm',
      token: token,
      body: {'paymentId': paymentId, 'status': status},
    );
  }
}
