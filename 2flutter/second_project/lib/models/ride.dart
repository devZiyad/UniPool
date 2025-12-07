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
  final DateTime? departureTimeStart;
  final DateTime? departureTimeEnd;
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
    this.departureTimeStart,
    this.departureTimeEnd,
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
    // Helper function to safely convert to int with field name for errors
    int toInt(dynamic value, String fieldName) {
      if (value == null) {
        throw Exception(
          'Required field "$fieldName" is null. Available keys: ${json.keys.join(", ")}',
        );
      }
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.parse(value.toString());
    }

    // Helper function to safely convert to double with field name for errors
    double toDouble(dynamic value, String fieldName) {
      if (value == null) {
        throw Exception(
          'Required field "$fieldName" is null. Available keys: ${json.keys.join(", ")}',
        );
      }
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.parse(value.toString());
    }

    // Helper function to safely convert nullable to double
    double? toDoubleNullable(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.parse(value.toString());
    }

    // Helper function to safely convert nullable to int
    int? toIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.parse(value.toString());
    }

    // Helper function to safely convert status (handle enum strings) with field name for errors
    String toString(dynamic value, String fieldName) {
      if (value == null) {
        throw Exception(
          'Required field "$fieldName" is null. Available keys: ${json.keys.join(", ")}',
        );
      }
      return value.toString();
    }

    // Handle both 'id' and 'rideId' field names (API changed)
    final rideId = json['rideId'] ?? json['id'];
    if (rideId == null) {
      throw Exception(
        'Neither "rideId" nor "id" found in response. Available keys: ${json.keys.join(", ")}',
      );
    }

    // Handle both 'departureTime' and 'departureTimeStart' field names (API changed)
    // Use departureTimeStart if available, otherwise fall back to departureTime
    final departureTimeValue =
        json['departureTimeStart'] ?? json['departureTime'];
    if (departureTimeValue == null) {
      throw Exception(
        'Neither "departureTimeStart" nor "departureTime" found in response. Available keys: ${json.keys.join(", ")}',
      );
    }

    // Parse departureTimeStart and departureTimeEnd if available
    DateTime? departureTimeStart;
    DateTime? departureTimeEnd;
    if (json['departureTimeStart'] != null) {
      departureTimeStart = DateTime.parse(
        toString(json['departureTimeStart'], 'departureTimeStart'),
      ).toLocal();
    }
    if (json['departureTimeEnd'] != null) {
      departureTimeEnd = DateTime.parse(
        toString(json['departureTimeEnd'], 'departureTimeEnd'),
      ).toLocal();
    }

    // Handle routePolyline - it can be a string or an object
    String? routePolylineStr;
    if (json['routePolyline'] != null) {
      if (json['routePolyline'] is String) {
        routePolylineStr = json['routePolyline'] as String;
      } else if (json['routePolyline'] is Map) {
        // If it's an object, convert to JSON string or extract coordinates
        routePolylineStr = json['routePolyline'].toString();
      } else {
        routePolylineStr = json['routePolyline'].toString();
      }
    }

    return Ride(
      id: toInt(rideId, 'id/rideId'),
      driverId: toInt(json['driverId'], 'driverId'),
      driverName: toString(json['driverName'], 'driverName'),
      driverRating: json['driverRating'] != null
          ? toDoubleNullable(json['driverRating'])
          : null,
      vehicleId: toInt(json['vehicleId'], 'vehicleId'),
      vehicleMake: toString(json['vehicleMake'], 'vehicleMake'),
      vehicleModel: toString(json['vehicleModel'], 'vehicleModel'),
      vehiclePlateNumber: toString(
        json['vehiclePlateNumber'],
        'vehiclePlateNumber',
      ),
      vehicleSeatCount: toInt(json['vehicleSeatCount'], 'vehicleSeatCount'),
      pickupLocationId: toInt(json['pickupLocationId'], 'pickupLocationId'),
      pickupLocationLabel: toString(
        json['pickupLocationLabel'],
        'pickupLocationLabel',
      ),
      pickupLatitude: toDouble(json['pickupLatitude'], 'pickupLatitude'),
      pickupLongitude: toDouble(json['pickupLongitude'], 'pickupLongitude'),
      destinationLocationId: toInt(
        json['destinationLocationId'],
        'destinationLocationId',
      ),
      destinationLocationLabel: toString(
        json['destinationLocationLabel'],
        'destinationLocationLabel',
      ),
      destinationLatitude: toDouble(
        json['destinationLatitude'],
        'destinationLatitude',
      ),
      destinationLongitude: toDouble(
        json['destinationLongitude'],
        'destinationLongitude',
      ),
      departureTime: DateTime.parse(
        toString(departureTimeValue, 'departureTime'),
      ).toLocal(),
      departureTimeStart: departureTimeStart,
      departureTimeEnd: departureTimeEnd,
      totalSeats: toInt(json['totalSeats'], 'totalSeats'),
      availableSeats: toInt(json['availableSeats'], 'availableSeats'),
      estimatedDistanceKm: json['estimatedDistanceKm'] != null
          ? toDoubleNullable(json['estimatedDistanceKm'])
          : null,
      routeDistanceKm: json['routeDistanceKm'] != null
          ? toDoubleNullable(json['routeDistanceKm'])
          : null,
      estimatedDurationMinutes: toIntNullable(json['estimatedDurationMinutes']),
      basePrice: json['basePrice'] != null
          ? toDoubleNullable(json['basePrice'])
          : null,
      pricePerSeat: json['pricePerSeat'] != null
          ? toDoubleNullable(json['pricePerSeat'])
          : null,
      status: toString(json['status'], 'status'),
      createdAt: DateTime.parse(
        toString(json['createdAt'], 'createdAt'),
      ).toLocal(),
      routePolyline: routePolylineStr,
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
