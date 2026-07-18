import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../models/user_settings.dart';
import 'api_client.dart';

class UserService {
  static Future<User> getCurrentUser() async {
    final response = await ApiClient.get('/users/me');
    return User.fromJson(jsonDecode(response.body));
  }

  static Future<User> getUserById(int userId) async {
    final response = await ApiClient.get('/users/$userId');
    return User.fromJson(jsonDecode(response.body));
  }

  static Future<User> updateProfile({
    required String fullName,
    String? phoneNumber,
  }) async {
    final response = await ApiClient.put('/users/me', {
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    });
    return User.fromJson(jsonDecode(response.body));
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await ApiClient.put('/users/me/password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  static Future<User> updateRole(String role) async {
    final response = await ApiClient.put('/users/me/role', {'role': role});
    return User.fromJson(jsonDecode(response.body));
  }

  static Future<UserSettings> getSettings() async {
    final response = await ApiClient.get('/users/me/settings');
    return UserSettings.fromJson(jsonDecode(response.body));
  }

  static Future<UserSettings> updateSettings({
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
  }) async {
    final Map<String, dynamic> body = {};
    if (emailNotifications != null)
      body['emailNotifications'] = emailNotifications;
    if (smsNotifications != null) body['smsNotifications'] = smsNotifications;
    if (pushNotifications != null)
      body['pushNotifications'] = pushNotifications;
    if (allowSmoking != null) body['allowSmoking'] = allowSmoking;
    if (allowPets != null) body['allowPets'] = allowPets;
    if (allowMusic != null) body['allowMusic'] = allowMusic;
    if (preferQuietRides != null) body['preferQuietRides'] = preferQuietRides;
    if (showPhoneNumber != null) body['showPhoneNumber'] = showPhoneNumber;
    if (showEmail != null) body['showEmail'] = showEmail;
    if (autoAcceptBookings != null)
      body['autoAcceptBookings'] = autoAcceptBookings;
    if (preferredPaymentMethod != null)
      body['preferredPaymentMethod'] = preferredPaymentMethod;

    final response = await ApiClient.put('/users/me/settings', body);
    return UserSettings.fromJson(jsonDecode(response.body));
  }

  /// Upload university ID image for verification
  ///
  /// [imageFile] - The XFile image to upload (works on both mobile and web)
  /// Returns the updated User object
  static Future<User> uploadUniversityId(XFile imageFile) async {
    // Read the image file and convert to base64
    // XFile.readAsBytes() works on both mobile and web platforms
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Determine the image type from MIME type or file extension
    String mimeType = 'image/jpeg'; // default
    if (imageFile.mimeType != null) {
      mimeType = imageFile.mimeType!;
    } else {
      // Fallback to extension-based detection
      final extension = imageFile.path.split('.').last.toLowerCase();
      mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
    }

    final imageData = 'data:$mimeType;base64,$base64Image';

    final response = await ApiClient.post('/users/me/upload-university-id', {
      'imageData': imageData,
    });
    return User.fromJson(jsonDecode(response.body));
  }

  /// Upload driver's license image for verification
  ///
  /// [imageFile] - The XFile image to upload (works on both mobile and web)
  /// Returns the updated User object
  static Future<User> uploadDriversLicense(XFile imageFile) async {
    // Read the image file and convert to base64
    // XFile.readAsBytes() works on both mobile and web platforms
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Determine the image type from MIME type or file extension
    String mimeType = 'image/jpeg'; // default
    if (imageFile.mimeType != null) {
      mimeType = imageFile.mimeType!;
    } else {
      // Fallback to extension-based detection
      final extension = imageFile.path.split('.').last.toLowerCase();
      mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
    }

    final imageData = 'data:$mimeType;base64,$base64Image';

    final response = await ApiClient.post('/users/me/upload-drivers-license', {
      'imageData': imageData,
    });
    return User.fromJson(jsonDecode(response.body));
  }
}
