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
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      rideId: json['rideId'] as int,
      riderId: json['riderId'] as int,
      riderName: json['riderName'] as String,
      seatsBooked: json['seatsBooked'] as int,
      status: json['status'] as String,
      costForThisRider: (json['costForThisRider'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
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

