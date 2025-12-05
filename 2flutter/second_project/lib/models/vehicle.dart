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
      id: json['id'],
      make: json['make'],
      model: json['model'],
      color: json['color'],
      plateNumber: json['plateNumber'],
      seatCount: json['seatCount'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      active: json['active'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
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
