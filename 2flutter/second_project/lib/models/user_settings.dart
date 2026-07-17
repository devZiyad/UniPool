class UserSettings {
  final int id;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool allowSmoking;
  final bool allowPets;
  final bool allowMusic;
  final bool preferQuietRides;
  final bool showPhoneNumber;
  final bool showEmail;
  final bool autoAcceptBookings;
  final String preferredPaymentMethod;

  UserSettings({
    required this.id,
    required this.emailNotifications,
    required this.smsNotifications,
    required this.pushNotifications,
    required this.allowSmoking,
    required this.allowPets,
    required this.allowMusic,
    required this.preferQuietRides,
    required this.showPhoneNumber,
    required this.showEmail,
    required this.autoAcceptBookings,
    required this.preferredPaymentMethod,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'],
      emailNotifications: json['emailNotifications'] ?? false,
      smsNotifications: json['smsNotifications'] ?? false,
      pushNotifications: json['pushNotifications'] ?? false,
      allowSmoking: json['allowSmoking'] ?? false,
      allowPets: json['allowPets'] ?? false,
      allowMusic: json['allowMusic'] ?? false,
      preferQuietRides: json['preferQuietRides'] ?? false,
      showPhoneNumber: json['showPhoneNumber'] ?? true,
      showEmail: json['showEmail'] ?? false,
      autoAcceptBookings: json['autoAcceptBookings'] ?? false,
      preferredPaymentMethod: json['preferredPaymentMethod'] ?? 'WALLET',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'pushNotifications': pushNotifications,
      'allowSmoking': allowSmoking,
      'allowPets': allowPets,
      'allowMusic': allowMusic,
      'preferQuietRides': preferQuietRides,
      'showPhoneNumber': showPhoneNumber,
      'showEmail': showEmail,
      'autoAcceptBookings': autoAcceptBookings,
      'preferredPaymentMethod': preferredPaymentMethod,
    };
  }

  UserSettings copyWith({
    int? id,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? allowSmoking,
    bool? allowPets,
    bool? allowMusic,
    bool? preferQuietRides,
    bool? showPhoneNumber,
    bool? showEmail,
    bool? autoAcceptBookings,
    String? preferredPaymentMethod,
  }) {
    return UserSettings(
      id: id ?? this.id,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      allowSmoking: allowSmoking ?? this.allowSmoking,
      allowPets: allowPets ?? this.allowPets,
      allowMusic: allowMusic ?? this.allowMusic,
      preferQuietRides: preferQuietRides ?? this.preferQuietRides,
      showPhoneNumber: showPhoneNumber ?? this.showPhoneNumber,
      showEmail: showEmail ?? this.showEmail,
      autoAcceptBookings: autoAcceptBookings ?? this.autoAcceptBookings,
      preferredPaymentMethod: preferredPaymentMethod ?? this.preferredPaymentMethod,
    );
  }
}

