import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../models/user_settings.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/app_drawer.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isLoadingSettings = false;
  bool _isSavingSettings = false;
  User? _user;
  UserSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadSettings();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await UserService.getCurrentUser();
      setState(() {
        _user = user;
        _fullNameController = TextEditingController(text: user.fullName);
        _phoneNumberController = TextEditingController(
          text: user.phoneNumber ?? '',
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoadingSettings = true;
    });

    try {
      final settings = await UserService.getSettings();
      setState(() {
        _settings = settings;
        _isLoadingSettings = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSettings = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading settings: $e')));
      }
    }
  }

  Future<void> _updateAutoAcceptBookings(bool value) async {
    setState(() {
      _isSavingSettings = true;
    });

    try {
      final updatedSettings = await UserService.updateSettings(
        autoAcceptBookings: value,
      );
      setState(() {
        _settings = updatedSettings;
        _isSavingSettings = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isSavingSettings = false;
        // Revert the toggle if update failed
        if (_settings != null) {
          _settings = _settings!.copyWith(autoAcceptBookings: !value);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating settings: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = await UserService.updateProfile(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty
            ? null
            : _phoneNumberController.text.trim(),
      );

      Provider.of<AuthProvider>(context, listen: false).setUser(updatedUser);

      if (mounted) {
        setState(() {
          _user = updatedUser;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Profile Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _fullNameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Save Changes'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Account Information Card
                    if (_user != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('Email', _user!.email),
                              _buildInfoRow(
                                'University ID',
                                _user!.universityId,
                              ),
                              _buildInfoRow('Role', _user!.role),
                              _buildInfoRow(
                                'Wallet Balance',
                                'BD ${_user!.walletBalance.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 8),
                              _buildVerificationStatus(
                                'University ID Verified',
                                _user!.universityIdVerified,
                                'Your university ID verification status',
                              ),
                              _buildVerificationStatus(
                                'Driver Verified',
                                _user!.verifiedDriver,
                                'Your driver verification status',
                              ),
                              if (_user!.avgRatingAsDriver != null)
                                _buildInfoRow(
                                  'Driver Rating',
                                  '${_user!.avgRatingAsDriver!.toStringAsFixed(1)} (${_user!.ratingCountAsDriver} reviews)',
                                ),
                              if (_user!.avgRatingAsRider != null)
                                _buildInfoRow(
                                  'Rider Rating',
                                  '${_user!.avgRatingAsRider!.toStringAsFixed(1)} (${_user!.ratingCountAsRider} reviews)',
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Settings Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isLoadingSettings)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_settings != null)
                              SwitchListTile(
                                title: const Text('Auto-Accept Bookings'),
                                subtitle: const Text(
                                  'Automatically accept booking requests without manual approval',
                                ),
                                value: _settings!.autoAcceptBookings,
                                onChanged: _isSavingSettings
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _settings = _settings!.copyWith(
                                            autoAcceptBookings: value,
                                          );
                                        });
                                        _updateAutoAcceptBookings(value);
                                      },
                                secondary: const Icon(Icons.check_circle_outline),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus(
    String label,
    bool isVerified,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle : Icons.pending,
                      color: isVerified ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isVerified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isVerified ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
