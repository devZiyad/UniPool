class Booking {
  final int id;
  final int rideId;
  final int riderId;
  final String riderName;
  final int seatsBooked;
  final String status;
  final double costForThisRider;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  // Additional fields from API
  final String? pickupLocationLabel;
  final String? dropoffLocationLabel;
  final DateTime? pickupTimeStart;
  final DateTime? pickupTimeEnd;
  // Additional fields for display
  final String? riderPhoneNumber;
  final double? riderRating;

  Booking({
    required this.id,
    required this.rideId,
    required this.riderId,
    required this.riderName,
    required this.seatsBooked,
    required this.status,
    required this.costForThisRider,
    required this.createdAt,
    this.cancelledAt,
    this.pickupLocationLabel,
    this.dropoffLocationLabel,
    this.pickupTimeStart,
    this.pickupTimeEnd,
    this.riderPhoneNumber,
    this.riderRating,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Handle both 'id' and 'bookingId' field names
    final id = json['id'] ?? json['bookingId'];
    // Handle both 'riderId' and 'passengerId' field names
    final riderId = json['riderId'] ?? json['passengerId'];
    // Handle both 'riderName' and 'passengerName' field names
    final riderName = json['riderName'] ?? json['passengerName'] ?? 'Unknown';

    // Validate required fields
    if (id == null) {
      throw Exception(
        'Booking ID is missing in response. Available keys: ${json.keys.join(", ")}',
      );
    }

    return Booking(
      id: id is int ? id : int.parse(id.toString()),
      rideId: json['rideId'] ?? 0,
      riderId: riderId != null
          ? (riderId is int ? riderId : int.parse(riderId.toString()))
          : 0,
      riderName: riderName,
      seatsBooked: json['seatsBooked'] ?? json['seats'] ?? 0,
      status: json['status'] ?? 'PENDING',
      costForThisRider: (json['costForThisRider'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      pickupLocationLabel: json['pickupLocationLabel'],
      dropoffLocationLabel: json['dropoffLocationLabel'],
      pickupTimeStart: json['pickupTimeStart'] != null
          ? DateTime.parse(json['pickupTimeStart']).toLocal()
          : null,
      pickupTimeEnd: json['pickupTimeEnd'] != null
          ? DateTime.parse(json['pickupTimeEnd']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'riderId': riderId,
      'riderName': riderName,
      'seatsBooked': seatsBooked,
      'status': status,
      'costForThisRider': costForThisRider,
      'createdAt': createdAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }
}
