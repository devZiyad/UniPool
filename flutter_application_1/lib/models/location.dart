class Location {
  final int id;
  final String label;
  final String? address;
  final double latitude;
  final double longitude;
  final int userId;
  final bool isFavorite;

  Location({
    required this.id,
    required this.label,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.isFavorite,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as int,
      label: json['label'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      userId: json['userId'] as int,
      isFavorite: json['isFavorite'] as bool? ?? false,
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

