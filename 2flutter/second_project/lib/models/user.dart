class User {
  final int id;
  final String universityId;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String role;
  final bool enabled;
  final DateTime createdAt;
  final double walletBalance;
  final double? avgRatingAsDriver;
  final int ratingCountAsDriver;
  final double? avgRatingAsRider;
  final int ratingCountAsRider;

  User({
    required this.id,
    required this.universityId,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    required this.enabled,
    required this.createdAt,
    required this.walletBalance,
    this.avgRatingAsDriver,
    required this.ratingCountAsDriver,
    this.avgRatingAsRider,
    required this.ratingCountAsRider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      universityId: json['universityId'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      enabled: json['enabled'],
      createdAt: DateTime.parse(json['createdAt']),
      walletBalance: (json['walletBalance'] ?? 0.0).toDouble(),
      avgRatingAsDriver: json['avgRatingAsDriver']?.toDouble(),
      ratingCountAsDriver: json['ratingCountAsDriver'] ?? 0,
      avgRatingAsRider: json['avgRatingAsRider']?.toDouble(),
      ratingCountAsRider: json['ratingCountAsRider'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'universityId': universityId,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'enabled': enabled,
      'createdAt': createdAt.toIso8601String(),
      'walletBalance': walletBalance,
      'avgRatingAsDriver': avgRatingAsDriver,
      'ratingCountAsDriver': ratingCountAsDriver,
      'avgRatingAsRider': avgRatingAsRider,
      'ratingCountAsRider': ratingCountAsRider,
    };
  }
}
