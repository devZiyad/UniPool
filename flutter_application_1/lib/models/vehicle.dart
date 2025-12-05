class Vehicle {
  final int id;
  final String make;
  final String model;
  final String? color;
  final String plateNumber;
  final int seatCount;
  final int ownerId;
  final String ownerName;
  final bool active;
  final DateTime createdAt;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    this.color,
    required this.plateNumber,
    required this.seatCount,
    required this.ownerId,
    required this.ownerName,
    required this.active,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      make: json['make'] as String,
      model: json['model'] as String,
      color: json['color'] as String?,
      plateNumber: json['plateNumber'] as String,
      seatCount: json['seatCount'] as int,
      ownerId: json['ownerId'] as int,
      ownerName: json['ownerName'] as String,
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'color': color,
      'plateNumber': plateNumber,
      'seatCount': seatCount,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

