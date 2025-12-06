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
    // Helper function to safely convert to int
    int _toInt(dynamic value) {
      if (value == null) throw Exception('Required field is null');
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.parse(value.toString());
    }

    // Helper function to safely convert to double
    double _toDouble(dynamic value) {
      if (value == null) throw Exception('Required field is null');
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.parse(value.toString());
    }

    // Helper function to safely convert nullable to double
    double? _toDoubleNullable(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.parse(value.toString());
    }

    // Helper function to safely convert status (handle enum strings)
    String _toString(dynamic value) {
      if (value == null) throw Exception('Required field is null');
      return value.toString();
    }

    return Ride(
      id: _toInt(json['id']),
      driverId: _toInt(json['driverId']),
      driverName: _toString(json['driverName']),
      driverRating: json['driverRating'] != null
          ? _toDoubleNullable(json['driverRating'])
          : null,
      vehicleId: _toInt(json['vehicleId']),
      vehicleMake: _toString(json['vehicleMake']),
      vehicleModel: _toString(json['vehicleModel']),
      vehiclePlateNumber: _toString(json['vehiclePlateNumber']),
      vehicleSeatCount: _toInt(json['vehicleSeatCount']),
      pickupLocationId: _toInt(json['pickupLocationId']),
      pickupLocationLabel: _toString(json['pickupLocationLabel']),
      pickupLatitude: _toDouble(json['pickupLatitude']),
      pickupLongitude: _toDouble(json['pickupLongitude']),
      destinationLocationId: _toInt(json['destinationLocationId']),
      destinationLocationLabel: _toString(json['destinationLocationLabel']),
      destinationLatitude: _toDouble(json['destinationLatitude']),
      destinationLongitude: _toDouble(json['destinationLongitude']),
      departureTime: DateTime.parse(_toString(json['departureTime'])).toLocal(),
      totalSeats: _toInt(json['totalSeats']),
      availableSeats: _toInt(json['availableSeats']),
      estimatedDistanceKm: json['estimatedDistanceKm'] != null
          ? _toDoubleNullable(json['estimatedDistanceKm'])
          : null,
      routeDistanceKm: json['routeDistanceKm'] != null
          ? _toDoubleNullable(json['routeDistanceKm'])
          : null,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] != null
          ? _toInt(json['estimatedDurationMinutes'])
          : null,
      basePrice: json['basePrice'] != null
          ? _toDoubleNullable(json['basePrice'])
          : null,
      pricePerSeat: json['pricePerSeat'] != null
          ? _toDoubleNullable(json['pricePerSeat'])
          : null,
      status: _toString(json['status']),
      createdAt: DateTime.parse(_toString(json['createdAt'])).toLocal(),
      routePolyline: json['routePolyline']?.toString(),
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
