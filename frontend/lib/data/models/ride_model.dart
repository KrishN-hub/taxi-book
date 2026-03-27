class RideModel {
  RideModel({
    required this.id,
    required this.status,
    required this.pickupAddress,
    required this.dropAddress,
    this.driverId,
    this.fareAmount,
  });

  final String id;
  final String status;
  final String pickupAddress;
  final String dropAddress;
  final String? driverId;
  final double? fareAmount;

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['_id'] as String,
      status: (json['status'] ?? 'requested') as String,
      pickupAddress: (json['pickup']?['address'] ?? '') as String,
      dropAddress: (json['drop']?['address'] ?? '') as String,
      driverId: json['driver'] is Map<String, dynamic>
          ? json['driver']['_id'] as String?
          : json['driver'] as String?,
      fareAmount: (json['fareAmount'] as num?)?.toDouble(),
    );
  }
}
