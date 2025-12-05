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
      id: json['id'] as int,
      universityId: json['universityId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String,
      enabled: json['enabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      walletBalance: (json['walletBalance'] as num).toDouble(),
      avgRatingAsDriver: json['avgRatingAsDriver'] != null
          ? (json['avgRatingAsDriver'] as num).toDouble()
          : null,
      ratingCountAsDriver: json['ratingCountAsDriver'] as int,
      avgRatingAsRider: json['avgRatingAsRider'] != null
          ? (json['avgRatingAsRider'] as num).toDouble()
          : null,
      ratingCountAsRider: json['ratingCountAsRider'] as int,
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

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

