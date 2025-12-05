class Location {
  final int id;
  final String label;
  final String? address;
  final double latitude;
  final double longitude;
  final int? userId;
  final bool isFavorite;

  Location({
    required this.id,
    required this.label,
    this.address,
    required this.latitude,
    required this.longitude,
    this.userId,
    required this.isFavorite,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      label: json['label'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      userId: json['userId'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
      'isFavorite': isFavorite,
    };
  }
}
