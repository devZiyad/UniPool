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
  final double estimatedDistanceKm;
  final double routeDistanceKm;
  final int estimatedDurationMinutes;
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
    required this.estimatedDistanceKm,
    required this.routeDistanceKm,
    required this.estimatedDurationMinutes,
    this.basePrice,
    this.pricePerSeat,
    required this.status,
    required this.createdAt,
    this.routePolyline,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as int,
      driverId: json['driverId'] as int,
      driverName: json['driverName'] as String,
      driverRating: json['driverRating'] != null
          ? (json['driverRating'] as num).toDouble()
          : null,
      vehicleId: json['vehicleId'] as int,
      vehicleMake: json['vehicleMake'] as String,
      vehicleModel: json['vehicleModel'] as String,
      vehiclePlateNumber: json['vehiclePlateNumber'] as String,
      vehicleSeatCount: json['vehicleSeatCount'] as int,
      pickupLocationId: json['pickupLocationId'] as int,
      pickupLocationLabel: json['pickupLocationLabel'] as String,
      pickupLatitude: (json['pickupLatitude'] as num).toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num).toDouble(),
      destinationLocationId: json['destinationLocationId'] as int,
      destinationLocationLabel: json['destinationLocationLabel'] as String,
      destinationLatitude: (json['destinationLatitude'] as num).toDouble(),
      destinationLongitude: (json['destinationLongitude'] as num).toDouble(),
      departureTime: DateTime.parse(json['departureTime'] as String),
      totalSeats: json['totalSeats'] as int,
      availableSeats: json['availableSeats'] as int,
      estimatedDistanceKm: (json['estimatedDistanceKm'] as num).toDouble(),
      routeDistanceKm: (json['routeDistanceKm'] as num).toDouble(),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int,
      basePrice: json['basePrice'] != null
          ? (json['basePrice'] as num).toDouble()
          : null,
      pricePerSeat: json['pricePerSeat'] != null
          ? (json['pricePerSeat'] as num).toDouble()
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      routePolyline: json['routePolyline'] as String?,
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

