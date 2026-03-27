import '../models/ride_model.dart';
import 'api_client.dart';

class RideService {
  RideService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<RideModel> requestRide({
    required String token,
    required String pickupAddress,
    required double pickupLng,
    required double pickupLat,
    required String dropAddress,
    required double dropLng,
    required double dropLat,
  }) async {
    final data = await _apiClient.post(
      '/rides/request',
      token: token,
      body: {
        'pickupAddress': pickupAddress,
        'pickupLng': pickupLng,
        'pickupLat': pickupLat,
        'dropAddress': dropAddress,
        'dropLng': dropLng,
        'dropLat': dropLat,
      },
    );

    return RideModel.fromJson(data['ride'] as Map<String, dynamic>);
  }

  Future<List<RideModel>> getRideHistory({required String token}) async {
    final data = await _apiClient.get('/rides/history', token: token);
    final rides = (data['rides'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => RideModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return rides;
  }
}
