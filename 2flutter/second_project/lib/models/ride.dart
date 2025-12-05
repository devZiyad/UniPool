class Ride {
  final int id;
  final int driverId;
  final String driverName;
  final double? driverRating;
  final int vehicleId;
  final String vehicleMake;
  final String vehicleModel;
  final String vehiclePlateNumber;
  final int vehicleSeatCount;
  final int pickupLocationId;
  final String pickupLocationLabel;
  final double pickupLatitude;
  final double pickupLongitude;
  final int destinationLocationId;
  final String destinationLocationLabel;
  final double destinationLatitude;
  final double destinationLongitude;
  final DateTime departureTime;
  final int totalSeats;
  final int availableSeats;
  final double? estimatedDistanceKm;
  final double? routeDistanceKm;
  final int? estimatedDurationMinutes;
  final double? basePrice;
  final double? pricePerSeat;
  final String status;
  final DateTime createdAt;
  final String? routePolyline;

  Ride({
    required this.id,
    required this.driverId,
    required this.driverName,
    this.driverRating,
    required this.vehicleId,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehiclePlateNumber,
    required this.vehicleSeatCount,
    required this.pickupLocationId,
    required this.pickupLocationLabel,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLocationId,
    required this.destinationLocationLabel,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.departureTime,
    required this.totalSeats,
    required this.availableSeats,
    this.estimatedDistanceKm,
    this.routeDistanceKm,
    this.estimatedDurationMinutes,
    this.basePrice,
    this.pricePerSeat,
    required this.status,
    required this.createdAt,
    this.routePolyline,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverRating: json['driverRating']?.toDouble(),
      vehicleId: json['vehicleId'],
      vehicleMake: json['vehicleMake'],
      vehicleModel: json['vehicleModel'],
      vehiclePlateNumber: json['vehiclePlateNumber'],
      vehicleSeatCount: json['vehicleSeatCount'],
      pickupLocationId: json['pickupLocationId'],
      pickupLocationLabel: json['pickupLocationLabel'],
      pickupLatitude: json['pickupLatitude'].toDouble(),
      pickupLongitude: json['pickupLongitude'].toDouble(),
      destinationLocationId: json['destinationLocationId'],
      destinationLocationLabel: json['destinationLocationLabel'],
      destinationLatitude: json['destinationLatitude'].toDouble(),
      destinationLongitude: json['destinationLongitude'].toDouble(),
      departureTime: DateTime.parse(json['departureTime']),
      totalSeats: json['totalSeats'],
      availableSeats: json['availableSeats'],
      estimatedDistanceKm: json['estimatedDistanceKm']?.toDouble(),
      routeDistanceKm: json['routeDistanceKm']?.toDouble(),
      estimatedDurationMinutes: json['estimatedDurationMinutes'],
      basePrice: json['basePrice']?.toDouble(),
      pricePerSeat: json['pricePerSeat']?.toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      routePolyline: json['routePolyline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'driverRating': driverRating,
      'vehicleId': vehicleId,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehiclePlateNumber': vehiclePlateNumber,
      'vehicleSeatCount': vehicleSeatCount,
      'pickupLocationId': pickupLocationId,
      'pickupLocationLabel': pickupLocationLabel,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destinationLocationId': destinationLocationId,
      'destinationLocationLabel': destinationLocationLabel,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'departureTime': departureTime.toIso8601String(),
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'estimatedDistanceKm': estimatedDistanceKm,
      'routeDistanceKm': routeDistanceKm,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'basePrice': basePrice,
      'pricePerSeat': pricePerSeat,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'routePolyline': routePolyline,
    };
  }
}
