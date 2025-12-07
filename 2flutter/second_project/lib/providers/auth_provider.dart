import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(email: email, password: password);
      _user = result['user'] as User;
      // Ensure role is DRIVER if university ID verification is pending
      if (_user != null && 
          !_user!.universityIdVerified && 
          _user!.role.toUpperCase() != 'DRIVER') {
        try {
          _user = await UserService.updateRole('DRIVER');
        } catch (e) {
          // If role update fails, keep the current user
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String universityId,
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String role = 'RIDER',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        universityId: universityId,
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
      );
      _user = result['user'] as User;
      // Ensure role is DRIVER if university ID verification is pending
      if (_user != null && 
          !_user!.universityIdVerified && 
          _user!.role.toUpperCase() != 'DRIVER') {
        try {
          _user = await UserService.updateRole('DRIVER');
        } catch (e) {
          // If role update fails, keep the current user
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await AuthService.getCurrentUser();
      // Ensure role is DRIVER if university ID verification is pending
      if (_user != null && 
          !_user!.universityIdVerified && 
          _user!.role.toUpperCase() != 'DRIVER') {
        try {
          _user = await UserService.updateRole('DRIVER');
        } catch (e) {
          // If role update fails, keep the current user
        }
      }
    } catch (e) {
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    // Ensure role is DRIVER if university ID verification is pending
    if (!user.universityIdVerified && user.role.toUpperCase() != 'DRIVER') {
      UserService.updateRole('DRIVER').then((updatedUser) {
        _user = updatedUser;
        notifyListeners();
      }).catchError((e) {
        // If role update fails, keep the current user
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }
}
